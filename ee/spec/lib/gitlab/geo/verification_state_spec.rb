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

    subject.verification_started
    subject.save!
  end

  subject { DummyModel.new }

  describe '#verification_succeeded_with_checksum!' do
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

      subject.verification_failed_with_message!('Failure to calculate checksum', error)

      expect(subject.reload.verification_failed?).to be_truthy
      expect(subject.reload.verification_failure).to eq 'Failure to calculate checksum: An error message'
      expect(subject.verification_retry_count).to be 1
    end
  end
end
