# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::AlertPayloadField do
  let(:alert_payload_field) { build(:alert_management_alert_payload_field) }

  describe 'validations' do
    subject { alert_payload_field }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_inclusion_of(:type).in_array(described_class::SUPPORTED_TYPES) }

    context 'validates path' do
      shared_examples 'has invalid path' do
        it 'is invalid' do
          expect(alert_payload_field.valid?).to eq(false)
          expect(alert_payload_field.errors.full_messages).to eq(['Path must be a list of strings or integers'])
        end
      end

      context 'when path is nil' do
        let(:alert_payload_field) { build(:alert_management_alert_payload_field, path: nil) }

        it_behaves_like 'has invalid path'
      end

      context 'when path is empty array' do
        let(:alert_payload_field) { build(:alert_management_alert_payload_field, path: []) }

        it_behaves_like 'has invalid path'
      end

      context 'when path does not contain only strings or integers' do
        let(:alert_payload_field) { build(:alert_management_alert_payload_field, path: ['title', {}]) }

        it_behaves_like 'has invalid path'
      end

      context 'when path contains only strings and integers' do
        let(:alert_payload_field) { build(:alert_management_alert_payload_field, path: ['title', 1]) }

        it { is_expected.to be_valid }
      end
    end
  end
end
