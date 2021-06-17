# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::PendingEscalations::Alert do
  subject { build(:incident_management_pending_alert_escalation) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:process_at) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to delegate_method(:project).to(:oncall_schedule) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:oncall_schedule) }
    it { is_expected.to belong_to(:alert) }
    it { is_expected.to belong_to(:rule) }
  end
end
