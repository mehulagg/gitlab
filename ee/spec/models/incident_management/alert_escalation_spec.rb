# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::AlertEscalation do
  subject { build(:incident_management_alert_escalation) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:policy) }
    it { is_expected.to belong_to(:alert) }
  end
end
