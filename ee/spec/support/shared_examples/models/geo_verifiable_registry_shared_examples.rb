# frozen_string_literal: true

# TODO: Include these examples in 'a Geo framework registry' when *all*
# registries are verifiable https://gitlab.com/gitlab-org/gitlab/-/issues/280768
RSpec.shared_examples 'a Geo verifiable registry' do
  let(:registry_class_factory) { described_class.underscore.tr('/', '_').to_sym }

  subject(:registry_record) { create(registry_class_factory, :synced) }

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
end
