# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationRule do
  let_it_be(:policy) { create(:incident_management_escalation_policy) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: policy.project) }

  subject { build(:incident_management_escalation_rule, policy: policy) }

  describe 'associations' do
    it { is_expected.to belong_to(:policy) }
    it { is_expected.to belong_to(:oncall_schedule) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:elapsed_time) }
    it { is_expected.to validate_numericality_of(:elapsed_time).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(24.hours) }
    it { is_expected.to validate_uniqueness_of(:policy_id).scoped_to([:oncall_schedule_id, :status, :elapsed_time] ) }
  end
end
