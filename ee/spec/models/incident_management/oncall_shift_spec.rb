# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallShift do
  # let_it_be(:rotation) { create(:incident_management_oncall_rotation) }

  describe '.associations' do
    it { is_expected.to belong_to(:oncall_rotation) }
    it { is_expected.to belong_to(:participant) }
  end

  describe '.validations' do
    # subject { build(:incident_management_oncall_shift, oncall_rotation: rotation) }
    subject { build(:incident_management_oncall_shift) }

    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }
  end
end
