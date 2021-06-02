# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationRule do
  let_it_be(:policy) { create(:incident_management_escalation_policy) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: policy.project) }

  subject { build(:incident_management_escalation_rule, policy: policy) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:policy) }
    it { is_expected.to belong_to(:oncall_schedule) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:elapsed_time_seconds) }
    it { is_expected.to validate_numericality_of(:elapsed_time_seconds).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(24.hours) }
    it { is_expected.to validate_uniqueness_of(:policy_id).scoped_to([:oncall_schedule_id, :status, :elapsed_time_seconds] ).with_message('must have a unique schedule, status, and elapsed time') }
  end

  describe 'scopes' do
    describe '.for_status_above' do
      subject { described_class.for_status_above(status) }

      let_it_be(:acknowledged_status_rule) { escalation_rule(policy: policy, status: AlertManagement::Alert::STATUSES[:acknowledged]) }
      let_it_be(:resolved_status_rule) { escalation_rule(policy: policy, status: AlertManagement::Alert::STATUSES[:resolved]) }

      let(:status) { AlertManagement::Alert::STATUSES[:acknowledged] }

      it { is_expected.to contain_exactly(resolved_status_rule) }
    end

    describe '.for_elapsed_time_between' do
      subject { described_class.for_elapsed_time_between(elapsed_min, elapsed_max) }

      let(:elapsed_min) { 60 }
      let(:elapsed_max) { 120 }

      let_it_be(:rule_60_seconds) { escalation_rule(elapsed_time_seconds: 60) }
      let_it_be(:rule_180_seconds) { escalation_rule(elapsed_time_seconds: 180) }

      it { is_expected.to contain_exactly(rule_60_seconds) }
    end
  end

  def escalation_rule(oncall_schedule: schedule, escalation_policy: policy, **attrs)
    create(:incident_management_escalation_rule, oncall_schedule: oncall_schedule, policy: escalation_policy, **attrs)
  end
end
