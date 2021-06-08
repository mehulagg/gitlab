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

  describe '#last_notified_at' do
    subject { described_class.new.last_notified_at }

    around do |example|
      freeze_time { example.run }
    end

    it { is_expected.to be_like_time(Time.current) }
  end
end
