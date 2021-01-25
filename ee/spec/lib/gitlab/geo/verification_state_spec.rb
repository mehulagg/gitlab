# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Geo::VerificationState do
  include ::EE::GeoHelpers

  let_it_be(:primary_node) { create(:geo_node, :primary) }
  let_it_be(:secondary_node) { create(:geo_node) }

  before(:all) do
    create_dummy_model_table
  end

  after(:all) do
    drop_dummy_model_table
  end

  before do
    stub_dummy_replicator_class
    stub_dummy_model_class
  end

  subject { DummyModel.new }

  describe '.verification_pending_batch' do
    # Insert 2 records for a total of 3 with subject
    let!(:other_pending_records) do
      DummyModel.insert_all([
        { verification_state: pending_value, verified_at: 7.days.ago },
        { verification_state: pending_value, verified_at: 6.days.ago }
      ], returning: [:id])
    end

    let(:pending_value) { DummyModel.verification_state_value(:verification_pending) }
    let(:other_pending_ids) { other_pending_records.map { |result| result['id'] } }

    before do
      subject.save!
    end

    it 'returns IDs of rows pending verification' do
      expect(subject.class.verification_pending_batch(batch_size: 3)).to include(subject.id)
    end

    it 'marks verification as started' do
      subject.class.verification_pending_batch(batch_size: 3)

      expect(subject.reload.verification_started?).to be_truthy
      expect(subject.verification_started_at).to be_present
    end

    it 'limits with batch_size and orders records by verified_at with NULLs first' do
      expected = [subject.id, other_pending_ids.first]

      # `match_array` instead of `eq` because the UPDATE query does not
      # guarantee that results are returned in the same order as the subquery
      # used to SELECT the correct batch.
      expect(subject.class.verification_pending_batch(batch_size: 2)).to match_array(expected)
    end

    context 'other verification states' do
      it 'does not include them' do
        subject.verification_started!

        expect(subject.class.verification_pending_batch(batch_size: 3)).not_to include(subject.id)

        subject.verification_succeeded_with_checksum!('foo', Time.current)

        expect(subject.class.verification_pending_batch(batch_size: 3)).not_to include(subject.id)

        subject.verification_started
        subject.verification_failed_with_message!('foo')

        expect(subject.class.verification_pending_batch(batch_size: 3)).not_to include(subject.id)
      end
    end
  end

  describe '.verification_failed_batch' do
    # Insert 2 records for a total of 3 with subject
    let!(:other_failed_records) do
      DummyModel.insert_all([
        { verification_state: failed_value, verification_retry_at: 7.days.ago },
        { verification_state: failed_value, verification_retry_at: 6.days.ago }
      ], returning: [:id])
    end

    let(:failed_value) { DummyModel.verification_state_value(:verification_failed) }
    let(:other_failed_ids) { other_failed_records.map { |result| result['id'] } }

    before do
      subject.verification_started!
      subject.verification_failed_with_message!('foo')
    end

    it 'returns IDs of rows pending verification' do
      expect(subject.class.verification_failed_batch(batch_size: 3)).to include(subject.id)
    end

    it 'marks verification as started' do
      subject.class.verification_failed_batch(batch_size: 3)

      expect(subject.reload.verification_started?).to be_truthy
      expect(subject.verification_started_at).to be_present
    end

    it 'limits with batch_size and orders records by verification_retry_at with NULLs first' do
      expected = other_failed_ids

      # `match_array` instead of `eq` because the UPDATE query does not
      # guarantee that results are returned in the same order as the subquery
      # used to SELECT the correct batch.
      expect(subject.class.verification_failed_batch(batch_size: 2)).to match_array(expected)
    end

    context 'other verification states' do
      it 'does not include them' do
        subject.verification_started!

        expect(subject.class.verification_failed_batch(batch_size: 5)).not_to include(subject.id)

        subject.verification_succeeded_with_checksum!('foo', Time.current)

        expect(subject.class.verification_failed_batch(batch_size: 5)).not_to include(subject.id)

        subject.verification_pending!

        expect(subject.class.verification_failed_batch(batch_size: 5)).not_to include(subject.id)
      end
    end
  end

  describe '.fail_verification_timeouts' do
    before do
      subject.verification_started!
    end

    context 'when verification has not timed out for a record' do
      it 'does not update verification state' do
        subject.update!(verification_started_at: (described_class::VERIFICATION_TIMEOUT - 1.minute).ago)

        DummyModel.fail_verification_timeouts

        expect(subject.reload.verification_started?).to be_truthy
      end
    end

    context 'when verification has timed out for a record' do
      it 'sets verification state to failed' do
        subject.update!(verification_started_at: (described_class::VERIFICATION_TIMEOUT + 1.minute).ago)

        DummyModel.fail_verification_timeouts

        expect(subject.reload.verification_failed?).to be_truthy
      end
    end
  end

  describe '#track_checksum_attempt!' do
    context 'when verification was not yet started' do
      it 'starts verification' do
        expect do
          subject.track_checksum_attempt! do
            'a_checksum_value'
          end
        end.to change { subject.verification_started_at }.from(nil)
      end

      it 'sets verification_succeeded' do
        expect do
          subject.track_checksum_attempt! do
            'a_checksum_value'
          end
        end.to change { subject.verification_succeeded? }.from(false).to(true)
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

  describe '#verification_succeeded_with_checksum!' do
    before do
      subject.verification_started!
    end

    context 'when the resource was updated during checksum calculation' do
      let(:calculation_started_at) { subject.verification_started_at - 1.second }

      it 'sets state to pending' do
        subject.verification_succeeded_with_checksum!('abc123', calculation_started_at)

        expect(subject.reload.verification_pending?).to be_truthy
      end
    end

    context 'when the resource was not updated during checksum calculation' do
      let(:calculation_started_at) { subject.verification_started_at + 1.second }

      it 'saves the checksum' do
        subject.verification_succeeded_with_checksum!('abc123', calculation_started_at)

        expect(subject.reload.verification_succeeded?).to be_truthy
        expect(subject.reload.verification_checksum).to eq('abc123')
        expect(subject.verified_at).not_to be_nil
      end
    end
  end

  describe '#verification_failed_with_message!' do
    it 'saves the error message and increments retry counter' do
      error = double('error', message: 'An error message')

      subject.verification_started!
      subject.verification_failed_with_message!('Failure to calculate checksum', error)

      expect(subject.reload.verification_failed?).to be_truthy
      expect(subject.reload.verification_failure).to eq 'Failure to calculate checksum: An error message'
      expect(subject.verification_retry_count).to be 1
      expect(subject.verification_checksum).to be_nil
    end
  end
end
