# frozen_string_literal: true

# TODO: Include these examples in 'a Geo framework registry' when *all*
# registries are verifiable https://gitlab.com/gitlab-org/gitlab/-/issues/280768
RSpec.shared_examples 'a Geo verifiable registry' do
  let(:registry_class_factory) { described_class.underscore.tr('/', '_').to_sym }

  subject(:registry_record) { create(registry_class_factory, :synced) }

  context 'state machine' do
    context 'when transitioning to synced' do
      it 'marks verification as pending' do
        registry = create(registry_class_factory, :started, :verification_succeeded)

        registry.synced!

        expect(registry.reload).to be_verification_pending
      end
    end
  end

  describe '.verification_pending_batch' do
    before do
      subject.save!
    end

    it 'returns IDs of rows which are synced and pending verification' do
      expect(described_class.verification_pending_batch(batch_size: 4)).to match_array([subject.model_record_id])
    end

    it 'excludes rows which are not synced or are not pending verification' do
      # rubocop:disable Rails/SaveBang
      create(registry_class_factory, verification_state: verification_state_value(:verification_pending))
      create(registry_class_factory, :started, verification_state: verification_state_value(:verification_pending))
      create(registry_class_factory, :failed, verification_state: verification_state_value(:verification_pending))
      create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_failed), verification_failure: 'foo')
      create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_started))
      create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_succeeded), verification_checksum: 'abc123')
      # rubocop:enable Rails/SaveBang

      expect(described_class.verification_pending_batch(batch_size: 4)).to match_array([subject.model_record_id])
    end

    it 'marks verification as started' do
      described_class.verification_pending_batch(batch_size: 4)

      expect(subject.reload.verification_started?).to be_truthy
      expect(subject.verification_started_at).to be_present
    end
  end

  describe '.verification_failed_batch' do
    before do
      subject.verification_failed_with_message!('foo')
    end

    context 'with a failed record with retry due' do
      before do
        subject.update!(verification_retry_at: 1.minute.ago)
      end

      it 'returns IDs of rows which are synced and have failed verification' do
        expect(described_class.verification_failed_batch(batch_size: 4)).to match_array([subject.model_record_id])
      end

      it 'excludes rows which are not synced or have not failed verification' do
        # rubocop:disable Rails/SaveBang
        create(registry_class_factory, verification_state: verification_state_value(:verification_failed), verification_failure: 'foo')
        create(registry_class_factory, :started, verification_state: verification_state_value(:verification_failed), verification_failure: 'foo')
        create(registry_class_factory, :failed, verification_state: verification_state_value(:verification_failed), verification_failure: 'foo')
        create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_pending))
        create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_started))
        create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_succeeded), verification_checksum: 'abc123')
        # rubocop:enable Rails/SaveBang

        expect(described_class.verification_failed_batch(batch_size: 4)).to match_array([subject.model_record_id])
      end

      it 'marks verification as started' do
        described_class.verification_failed_batch(batch_size: 4)

        expect(subject.reload.verification_started?).to be_truthy
        expect(subject.verification_started_at).to be_present
      end
    end

    context 'when verification_retry_at is in the future' do
      it 'does not return the row which failed verification' do
        subject.update!(verification_retry_at: 1.minute.from_now)

        expect(subject.class.verification_failed_batch(batch_size: 4)).not_to include(subject.model_record_id)
      end
    end
  end

  describe '.needs_verification_count' do
    before do
      subject.save!
    end

    it 'returns the number of rows which are synced and pending verification' do
      expect(described_class.needs_verification_count(limit: 3)).to eq(1)
    end

    it 'includes rows which are synced and failed verification and are due for retry' do
      create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_failed), verification_failure: 'foo', verification_retry_at: 1.minute.ago) # rubocop:disable Rails/SaveBang

      expect(described_class.needs_verification_count(limit: 3)).to eq(2)
    end

    it 'excludes rows which are synced and failed verification and have a future retry time' do
      create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_failed), verification_failure: 'foo', verification_retry_at: 1.minute.from_now) # rubocop:disable Rails/SaveBang

      expect(described_class.needs_verification_count(limit: 3)).to eq(1)
    end

    it 'excludes rows which are not synced or are not (pending or failed) verification' do
      # rubocop:disable Rails/SaveBang
      create(registry_class_factory, verification_state: verification_state_value(:verification_pending))
      create(registry_class_factory, :started, verification_state: verification_state_value(:verification_pending))
      create(registry_class_factory, :failed, verification_state: verification_state_value(:verification_pending))
      create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_started))
      create(registry_class_factory, :synced, verification_state: verification_state_value(:verification_succeeded), verification_checksum: 'abc123')
      # rubocop:enable Rails/SaveBang

      expect(described_class.needs_verification_count(limit: 3)).to eq(1)
    end
  end

  describe '#verification_succeeded!', :aggregate_failures do
    before do
      subject.verification_started!
    end

    it 'clears checksum mismatch fields' do
      subject.update!(checksum_mismatch: true, verification_checksum_mismatched: 'abc123')
      subject.verification_checksum = 'abc123'

      expect do
        subject.verification_succeeded!
      end.to change { subject.verification_succeeded? }.from(false).to(true)

      expect(subject.checksum_mismatch).to eq(false)
      expect(subject.verification_checksum_mismatched).to eq(nil)
    end
  end

  describe '#track_checksum_attempt!', :aggregate_failures do
    context 'when verification was not yet started' do
      it 'starts verification' do
        expect do
          subject.track_checksum_attempt! do
            'a_checksum_value'
          end
        end.to change { subject.verification_started_at }.from(nil)
      end

      context 'comparison with primary checksum' do
        let(:replicator) { double('replicator') }
        let(:calculated_checksum) { 'abc123' }

        before do
          allow(subject).to receive(:replicator).and_return(replicator)
          allow(replicator).to receive(:matches_checksum?).with(calculated_checksum).and_return(matches_checksum)
        end

        context 'when the calculated checksum matches the primary checksum' do
          let(:matches_checksum) { true }

          it 'transitions to verification_succeeded and updates the checksum' do
            expect do
              subject.track_checksum_attempt! do
                calculated_checksum
              end
            end.to change { subject.verification_succeeded? }.from(false).to(true)

            expect(subject.verification_checksum).to eq(calculated_checksum)
          end
        end

        context 'when the calculated checksum does not match the primary checksum' do
          let(:matches_checksum) { false }

          it 'transitions to verification_failed and updates mismatch fields' do
            allow(replicator).to receive(:primary_checksum).and_return(calculated_checksum)

            expect do
              subject.track_checksum_attempt! do
                calculated_checksum
              end
            end.to change { subject.verification_failed? }.from(false).to(true)

            expect(subject.verification_checksum).to eq(calculated_checksum)
            expect(subject.verification_checksum_mismatched).to eq(calculated_checksum)
            expect(subject.checksum_mismatch).to eq(true)
            expect(subject.verification_failure).to match('Checksum does not match the primary checksum')
          end
        end
      end
    end

    context 'when verification was started' do
      it 'does not update verification_started_at' do
        subject.verification_started!
        expected = subject.verification_started_at

        subject.track_checksum_attempt! do
          'a_checksum_value'
        end

        expect(subject.verification_started_at).to be_within(1.second).of(expected)
      end
    end

    it 'yields to the checksum calculation' do
      expect do |probe|
        subject.track_checksum_attempt!(&probe)
      end.to yield_with_no_args
    end

    context 'when an error occurs while yielding' do
      it 'sets verification_failed' do
        subject.track_checksum_attempt! do
          raise 'an error'
        end

        expect(subject.reload.verification_failed?).to be_truthy
      end
    end
  end

  def verification_state_value(key)
    described_class.verification_state_value(key)
  end
end
