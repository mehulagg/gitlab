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

  describe '.checksummed_count' do
    context 'when verification is enabled' do
      before do
        allow(described_class).to receive(:verification_enabled?).and_return(true)
      end

      it 'returns the number of available replicables where verification succeeded' do
        model_record.verification_started!
        model_record.verification_succeeded_with_checksum!('some checksum', Time.current)

        expect(described_class.checksummed_count).to eq(1)
      end

      it 'excludes other verification states' do
        model_record.verification_started!

        expect(described_class.checksummed_count).to eq(0)

        model_record.verification_failed_with_message!('some error message')

        expect(described_class.checksummed_count).to eq(0)

        model_record.verification_pending!

        expect(described_class.checksummed_count).to eq(0)
      end
    end

    context 'when verification is disabled' do
      it 'returns nil' do
        allow(described_class).to receive(:verification_enabled?).and_return(false)

        expect(described_class.checksummed_count).to be_nil
      end
    end
  end

  describe '.checksum_failed_count' do
    context 'when verification is enabled' do
      before do
        allow(described_class).to receive(:verification_enabled?).and_return(true)
      end

      it 'returns the number of available replicables where verification failed' do
        model_record.verification_started!
        model_record.verification_failed_with_message!('some error message')

        expect(described_class.checksum_failed_count).to eq(1)
      end

      it 'excludes other verification states' do
        model_record.verification_started!

        expect(described_class.checksum_failed_count).to eq(0)

        model_record.verification_succeeded_with_checksum!('foo', Time.current)

        expect(described_class.checksum_failed_count).to eq(0)

        model_record.verification_pending!

        expect(described_class.checksum_failed_count).to eq(0)
      end
    end

    context 'when verification is disabled' do
      it 'returns nil' do
        allow(described_class).to receive(:verification_enabled?).and_return(false)

        expect(described_class.checksum_failed_count).to be_nil
      end
    end
  end

  describe '.trigger_background_verification' do
    context 'when verification is enabled' do
      before do
        allow(described_class).to receive(:verification_enabled?).and_return(true)
      end

      it 'enqueues VerificationBatchWorker' do
        expect(::Geo::VerificationBatchWorker).to receive(:perform_with_capacity).with(described_class.replicable_name)

        described_class.trigger_background_verification
      end

      it 'enqueues VerificationTimeoutWorker' do
        expect(::Geo::VerificationTimeoutWorker).to receive(:perform_async).with(described_class.replicable_name)

        described_class.trigger_background_verification
      end
    end

    context 'when verification is disabled' do
      before do
        allow(described_class).to receive(:verification_enabled?).and_return(false)
      end

      it 'does not enqueue VerificationBatchWorker' do
        expect(::Geo::VerificationBatchWorker).not_to receive(:perform_with_capacity)

        described_class.trigger_background_verification
      end

      it 'does not enqueue VerificationTimeoutWorker' do
        expect(::Geo::VerificationTimeoutWorker).not_to receive(:perform_async)

        described_class.trigger_background_verification
      end
    end
  end

  describe '.verify_batch' do
    context 'when there are records needing verification' do
      let(:another_replicator) { double('another_replicator', verify: true) }
      let(:replicators) { [replicator, another_replicator] }

      before do
        allow(described_class).to receive(:replicator_batch_to_verify).and_return(replicators)
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

  describe '.replicator_batch_to_verify' do
    it 'returns usable Replicator instances' do
      model_record.save!

      expect(described_class).to receive(:model_record_id_batch_to_verify).and_return([model_record.id])

      first_result = described_class.replicator_batch_to_verify.first

      expect(first_result.class).to eq(described_class)
      expect(first_result.model_record_id).to eq(model_record.id)
    end
  end

  describe '.model_record_id_batch_to_verify' do
    let(:pending_ids) { [1, 2] }

    before do
      allow(described_class).to receive(:verification_batch_size).and_return(verification_batch_size)
      allow(described_class).to receive(:verification_pending_batch).with(batch_size: verification_batch_size).and_return(pending_ids)
    end

    context 'when the batch is filled by pending rows' do
      let(:verification_batch_size) { 2 }

      it 'returns IDs of pending rows' do
        expect(described_class.model_record_id_batch_to_verify).to eq(pending_ids)
      end

      it 'does not call .verification_failed_batch' do
        expect(described_class).not_to receive(:verification_failed_batch)

        described_class.model_record_id_batch_to_verify
      end
    end

    context 'when that batch is not filled by pending rows' do
      let(:failed_ids) { [3, 4, 5] }
      let(:verification_batch_size) { 5 }

      it 'includes IDs of failed rows' do
        remaining_capacity = verification_batch_size - pending_ids.size

        allow(described_class).to receive(:verification_failed_batch).with(batch_size: remaining_capacity).and_return(failed_ids)

        result = described_class.model_record_id_batch_to_verify

        expect(result).to include(*pending_ids)
        expect(result).to include(*failed_ids)
      end
    end
  end

  describe '.verification_pending_batch' do
    context 'when current node is a primary' do
      it 'delegates to the model class of the replicator' do
        expect(described_class.model).to receive(:verification_pending_batch)

        described_class.verification_pending_batch
      end
    end

    context 'when current node is a secondary' do
      it 'delegates to the registry class of the replicator' do
        stub_current_geo_node(secondary)

        expect(described_class.registry_class).to receive(:verification_pending_batch)

        described_class.verification_pending_batch
      end
    end
  end

  describe '.verification_failed_batch' do
    context 'when current node is a primary' do
      it 'delegates to the model class of the replicator' do
        expect(described_class.model).to receive(:verification_failed_batch)

        described_class.verification_failed_batch
      end
    end

    context 'when current node is a secondary' do
      it 'delegates to the registry class of the replicator' do
        stub_current_geo_node(secondary)

        expect(described_class.registry_class).to receive(:verification_failed_batch)

        described_class.verification_failed_batch
      end
    end
  end

  describe '.fail_verification_timeouts' do
    context 'when current node is a primary' do
      it 'delegates to the model class of the replicator' do
        expect(described_class.model).to receive(:fail_verification_timeouts)

        described_class.fail_verification_timeouts
      end
    end

    context 'when current node is a secondary' do
      it 'delegates to the registry class of the replicator' do
        stub_current_geo_node(secondary)

        expect(described_class.registry_class).to receive(:fail_verification_timeouts)

        described_class.fail_verification_timeouts
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
    it 'wraps the checksum calculation in track_checksum_attempt!' do
      tracker = double('tracker', calculate_checksum: 'abc123')
      allow(replicator).to receive(:model_record).and_return(tracker)

      expect(tracker).to receive(:track_checksum_attempt!).and_yield

      replicator.verify
    end
  end

  context 'integration tests' do
    before do
      model_record.save!
    end

    context 'on a primary' do
      before do
        stub_primary_node
      end

      describe 'background backfill' do
        it 'verifies model records' do
          expect do
            Geo::VerificationBatchWorker.new.perform(replicator.replicable_name)
          end.to change { model_record.reload.verification_succeeded? }.from(false).to(true)
        end
      end

      describe 'triggered by events' do
        it 'verifies model records' do
          expect do
            Geo::VerificationWorker.new.perform(replicator.replicable_name, replicator.model_record_id)
          end.to change { model_record.reload.verification_succeeded? }.from(false).to(true)
        end
      end
    end
  end
end
