# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::AlertPayloadField do
  let(:alert_payload_field) { build_stubbed(:alert_management_alert_payload_field) }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_inclusion_of(:type).in_array(described_class::SUPPORTED_TYPES) }

    describe '#path_is_list_of_strings' do
      before do
        alert_management_alert_payload_field.path = path
        alert_management_alert_payload_field.valid?
      end

      context 'when path is nil'
      context 'when path is empty array'
      context 'when path does not contain only strings'
    end
  end
end
