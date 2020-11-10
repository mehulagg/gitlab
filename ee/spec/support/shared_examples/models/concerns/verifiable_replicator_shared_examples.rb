# frozen_string_literal: true

# This is included by BlobReplicatorStrategy and RepositoryReplicatorStrategy.
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

  describe '#after_verifiable_update' do
    it 'calls verify_async if needed' do
      expect(replicator).to receive(:verify_async)
      expect(replicator).to receive(:needs_checksum?).and_return(true)

      replicator.after_verifiable_update
    end
  end

  describe '#verify' do
    before do
      model_record.verification_started
      model_record.save!
    end

    context 'when a Geo primary' do
      context 'when an error is raised during calculate_checksum' do
        it 'delegates checksum calculation and the state change to model_record' do
          expect(model_record).to receive(:calculate_checksum).and_return('abc123')
          expect(model_record).to receive(:verification_succeeded_with_checksum!).with('abc123')

          replicator.verify
        end

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
  end
end
