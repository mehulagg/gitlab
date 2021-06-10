# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::AlertEscalation do
  subject { build(:incident_management_alert_escalation) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:policy) }
    it { is_expected.to belong_to(:alert) }
  end

  it { is_expected.to delegate_method(:project).to(:policy) }

  describe '#time_since_last_notify' do
    let(:escalation) { build(:incident_management_alert_escalation) }

    subject { escalation.time_since_last_notify }

    it { is_expected.to eq(0) }

    context 'when last_notified_at is set' do
      let(:created_at) { 1.hour.ago }
      let(:last_notified_at) { Time.current }
      let(:escalation) { create(:incident_management_alert_escalation, created_at: created_at, last_notified_at: last_notified_at) }

      it { is_expected.to eql(last_notified_at - created_at) }
    end
  end
end
