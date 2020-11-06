# frozen_string_literal: true

# This should be included on any Replicator which implements verification.
#
# Expected let variables:
#
# - primary
# - secondary
# - model_record
# - replicator
#
RSpec.shared_examples 'a verifiable replicator' do
  include EE::GeoHelpers

  describe '.verification_enabled?' do
    context 'when replication is enabled' do
      before do
        expect(described_class).to receive(:enabled?).and_return(true)
      end

      context 'when the verification feature flag is enabled' do
        it 'returns true' do
          allow(described_class).to receive(:verification_feature_flag_enabled?).and_return(true)

          expect(described_class.verification_enabled?).to be_truthy
        end
      end

      context 'when geo_framework_verification feature flag is disabled' do
        it 'returns false' do
          allow(described_class).to receive(:verification_feature_flag_enabled?).and_return(false)

          expect(described_class.verification_enabled?).to be_falsey
        end
      end
    end

    context 'when replication is disabled' do
      before do
        expect(described_class).to receive(:enabled?).and_return(false)
      end

      it 'returns false' do
        expect(described_class.verification_enabled?).to be_falsey
      end
    end
  end

  describe '.trigger_background_verification' do
    context 'when verification is enabled' do
      before do
        expect(described_class).to receive(:verification_enabled?).and_return(true)
      end

      it 'enqueues VerificationBatchWorker' do
        expect(::Geo::VerificationBatchWorker).to receive(:perform_with_capacity).with(described_class.replicable_name)

        described_class.trigger_background_verification
      end
    end

    context 'when verification is disabled' do
      before do
        expect(described_class).to receive(:verification_enabled?).and_return(false)
      end

      it 'does not enqueue VerificationBatchWorker' do
        expect(::Geo::VerificationBatchWorker).not_to receive(:perform_with_capacity)

        described_class.trigger_background_verification
      end
    end
  end

  describe '.verify_batch' do
    context 'when there are records needing verification' do
      let(:another_replicator) { double('another_replicator', verify: true) }
      let(:replicators) { [replicator, another_replicator] }

      before do
        allow(described_class).to receive(:replicators_to_verify).and_return(replicators)
      end

      it 'calls #verify on each replicator' do
        expect(replicator).to receive(:verify)
        expect(another_replicator).to receive(:verify)

        described_class.verify_batch
      end
    end
  end

  describe '.remaining_verification_batch_count' do
    it 'converts needs_verification_count to number of batches' do
      expected_limit = 40
      expect(described_class).to receive(:needs_verification_count).with(limit: expected_limit).and_return(21)

      expect(described_class.remaining_verification_batch_count(max_batch_count: 4)).to eq(3)
    end
  end

  describe '.replicators_to_verify' do
    it 'returns usable Replicator instances' do
      model_record.save!

      expect(described_class).to receive(:model_record_ids_batch_to_verify).and_return([model_record.id])

      first_result = described_class.replicators_to_verify.first

      expect(first_result.class).to eq(described_class)
      expect(first_result.model_record_id).to eq(model_record.id)
    end
  end

  describe '.model_record_ids_batch_to_verify' do
    let(:ids_never_attempted) { [1, 2] }

    before do
      allow(described_class).to receive(:verification_batch_size).and_return(verification_batch_size)
      allow(described_class).to receive(:model_record_ids_never_attempted_verification).with(batch_size: verification_batch_size).and_return(ids_never_attempted)
    end

    context 'when the batch is filled by records that were never verified' do
      let(:verification_batch_size) { 2 }

      it 'returns IDs of records that have never attempted verification' do
        expect(described_class.model_record_ids_batch_to_verify).to eq(ids_never_attempted)
      end

      it 'does not call .model_record_ids_needs_verification_again' do
        expect(described_class).not_to receive(:model_record_ids_needs_verification_again)

        described_class.model_record_ids_batch_to_verify
      end
    end

    context 'when that batch is not filled by records that were never verified' do
      let(:ids_needs_verification_again) { [3, 4, 5] }
      let(:verification_batch_size) { 5 }

      it 'includes IDs of records that need to be verified again' do
        remaining_capacity = verification_batch_size - ids_never_attempted.size

        allow(described_class).to receive(:model_record_ids_needs_verification_again).with(batch_size: remaining_capacity).and_return(ids_needs_verification_again)

        result = described_class.model_record_ids_batch_to_verify

        expect(result).to include(*ids_never_attempted)
        expect(result).to include(*ids_needs_verification_again)
      end
    end
  end

  describe '.model_record_ids_never_attempted_verification' do
    context 'when current node is a primary' do
      it 'delegates to the model class of the replicator' do
        expect(described_class.model).to receive(:model_record_ids_never_attempted_verification)

        described_class.model_record_ids_never_attempted_verification
      end
    end

    context 'when current node is a secondary' do
      it 'delegates to the registry class of the replicator' do
        stub_current_geo_node(secondary)

        expect(described_class.registry_class).to receive(:model_record_ids_never_attempted_verification)

        described_class.model_record_ids_never_attempted_verification
      end
    end
  end

  describe '.model_record_ids_needs_verification_again' do
    context 'when current node is a primary' do
      it 'delegates to the model class of the replicator' do
        expect(described_class.model).to receive(:model_record_ids_needs_verification_again)

        described_class.model_record_ids_needs_verification_again
      end
    end

    context 'when current node is a secondary' do
      it 'delegates to the registry class of the replicator' do
        stub_current_geo_node(secondary)

        expect(described_class.registry_class).to receive(:model_record_ids_needs_verification_again)

        described_class.model_record_ids_needs_verification_again
      end
    end
  end

  describe '#after_verifiable_update' do
    it 'calls verify_async if needed' do
      expect(replicator).to receive(:verify_async)
      expect(replicator).to receive(:needs_checksum?).and_return(true)

      replicator.after_verifiable_update
    end
  end

  describe '#verify_async' do
    before do
      model_record.save!
    end

    context 'on a Geo primary' do
      before do
        stub_primary_node
      end

      it 'calls verification_started! and enqueues VerificationWorker' do
        expect(model_record).to receive(:verification_started!)
        expect(Geo::VerificationWorker).to receive(:perform_async).with(replicator.replicable_name, model_record.id)

        replicator.verify_async
      end
    end
  end

  describe '#verify' do
    context 'on a Geo primary' do
      before do
        stub_primary_node
      end

      context 'when verification was started' do
        before do
          model_record.verification_started!
        end

        context 'when the checksum succeeds' do
          it 'delegates checksum calculation and the state change to model_record' do
            expect(model_record).to receive(:calculate_checksum).and_return('abc123')
            expect(model_record).to receive(:verification_succeeded_with_checksum!).with('abc123', kind_of(Time))

            replicator.verify
          end
        end

        context 'when an error is raised during calculate_checksum' do
          it 'passes the error message' do
            error = StandardError.new('Some exception')
            allow(model_record).to receive(:calculate_checksum) do
              raise error
            end

            expect(model_record).to receive(:verification_failed_with_message!).with('Error calculating the checksum', error)

            replicator.verify
          end
        end
      end

      context 'when verification was not started' do
        it 'does not call calculate_checksum!' do
          expect(model_record).not_to receive(:calculate_checksum)

          replicator.verify
        end
      end
    end
  end
end
