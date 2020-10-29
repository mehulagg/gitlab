# frozen_string_literal: true

# This is included by BlobReplicatorStrategy and RepositoryReplicatorStrategy.
#
RSpec.shared_examples 'a verifiable replicator' do
  include EE::GeoHelpers

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
