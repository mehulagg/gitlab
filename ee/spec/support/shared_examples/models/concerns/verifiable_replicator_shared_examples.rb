# frozen_string_literal: true

# This is included by BlobReplicatorStrategy and RepositoryReplicatorStrategy.
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

  describe '.enqueue_checksum_batch_worker' do
    it 'enqueues ChecksumBatchWorker' do
      expect(::Geo::ChecksumBatchWorker).to receive(:perform_with_capacity).with(described_class)

      described_class.enqueue_checksum_batch_worker
    end
  end

  describe '.batch_calculate_checksum' do
    context 'when there are records needing checksum' do
      let(:another_replicator) { double('another_replicator', calculate_checksum!: true) }
      let(:replicators) { [replicator, another_replicator] }

      before do
        allow(described_class).to receive(:replicators_to_checksum).and_return(replicators)
      end

      it 'calls #calculate_checksum! on each replicator' do
        expect(replicator).to receive(:calculate_checksum!)
        expect(another_replicator).to receive(:calculate_checksum!)

        described_class.batch_calculate_checksum
      end
    end
  end

  describe '.remaining_checksum_batch_count' do
    it 'converts needs_verification_count to number of batches' do
      expected_limit = 40
      expect(described_class).to receive(:needs_verification_count).with(limit: expected_limit).and_return(21)

      expect(described_class.remaining_checksum_batch_count(max_batch_count: 4)).to eq(3)
    end
  end

  describe '.replicators_to_checksum' do
    it 'returns usable Replicator instances' do
      model_record.save!

      expect(described_class).to receive(:model_record_ids_batch_to_checksum).and_return([model_record.id])

      first_result = described_class.replicators_to_checksum.first

      expect(first_result.class).to eq(described_class)
      expect(first_result.model_record_id).to eq(model_record.id)
    end
  end

  describe '.model_record_ids_batch_to_checksum' do
    let(:ids_never_attempted) { [1, 2] }

    before do
      allow(described_class).to receive(:checksum_batch_size).and_return(checksum_batch_size)
      allow(described_class).to receive(:model_record_ids_never_attempted_checksum).with(batch_size: checksum_batch_size).and_return(ids_never_attempted)
    end

    context 'when the batch is filled by records that were never checksummed' do
      let(:checksum_batch_size) { 2 }

      it 'returns IDs of records that have never attempted checksum' do
        expect(described_class.model_record_ids_batch_to_checksum).to eq(ids_never_attempted)
      end

      it 'does not call .model_record_ids_needs_checksum_again' do
        expect(described_class).not_to receive(:model_record_ids_needs_checksum_again)

        described_class.model_record_ids_batch_to_checksum
      end
    end

    context 'when that batch is not filled by records that were never checksummed' do
      let(:ids_needs_checksum_again) { [3, 4, 5] }
      let(:checksum_batch_size) { 5 }

      it 'includes IDs of records that need to be checksummed again' do
        remaining_capacity = checksum_batch_size - ids_never_attempted.size

        allow(described_class).to receive(:model_record_ids_needs_checksum_again).with(batch_size: remaining_capacity).and_return(ids_needs_checksum_again)

        result = described_class.model_record_ids_batch_to_checksum

        expect(result).to include(*ids_never_attempted)
        expect(result).to include(*ids_needs_checksum_again)
      end
    end
  end

  describe '.model_record_ids_never_attempted_checksum' do
    context 'when current node is a primary' do
      it 'delegates to the model class of the replicator' do
        expect(described_class.model).to receive(:model_record_ids_never_attempted_checksum)

        described_class.model_record_ids_never_attempted_checksum
      end
    end

    context 'when current node is a secondary' do
      it 'delegates to the registry class of the replicator' do
        stub_current_geo_node(secondary)

        expect(described_class.registry_class).to receive(:model_record_ids_never_attempted_checksum)

        described_class.model_record_ids_never_attempted_checksum
      end
    end
  end

  describe '.model_record_ids_needs_checksum_again' do
    context 'when current node is a primary' do
      it 'delegates to the model class of the replicator' do
        expect(described_class.model).to receive(:model_record_ids_needs_checksum_again)

        described_class.model_record_ids_needs_checksum_again
      end
    end

    context 'when current node is a secondary' do
      it 'delegates to the registry class of the replicator' do
        stub_current_geo_node(secondary)

        expect(described_class.registry_class).to receive(:model_record_ids_needs_checksum_again)

        described_class.model_record_ids_needs_checksum_again
      end
    end
  end

  describe '#after_verifiable_update' do
    it 'schedules the checksum calculation if needed' do
      expect(replicator).to receive(:schedule_checksum_calculation)
      expect(replicator).to receive(:needs_checksum?).and_return(true)

      replicator.after_verifiable_update
    end
  end

  describe '#calculate_checksum!' do
    it 'calculates the checksum' do
      model_record.save!

      replicator.calculate_checksum!

      expect(model_record.reload.verification_checksum).not_to be_nil
      expect(model_record.reload.verified_at).not_to be_nil
    end

    it 'saves the error message and increments retry counter' do
      model_record.save!

      allow(model_record).to receive(:calculate_checksum!) do
        raise StandardError.new('Failure to calculate checksum')
      end

      replicator.calculate_checksum!

      expect(model_record.reload.verification_failure).to eq 'Failure to calculate checksum'
      expect(model_record.verification_retry_count).to be 1
    end
  end
end
