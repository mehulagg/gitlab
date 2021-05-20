# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationRule do
  let_it_be(:policy) { create(:incident_management_escalation_policy) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: policy.project) }

  let(:rule) { build(:incident_management_escalation_rule, policy: policy) }

  subject { rule }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:policy) }
    it { is_expected.to belong_to(:oncall_schedule) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:elapsed_time_seconds) }
    it { is_expected.to validate_numericality_of(:elapsed_time_seconds).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(24.hours) }
    it { is_expected.to validate_uniqueness_of(:policy_id).scoped_to([:oncall_schedule_id, :status, :elapsed_time_seconds] ).with_message('Must have a unique policy, status, and elapsed time') }

    describe 'oncall_schedule_same_project_as_policy' do
      context 'schedule is from another project' do
        let(:other_project_schedule) { create(:incident_management_oncall_schedule) }
        let(:rule) { build(:incident_management_escalation_rule, policy: policy, oncall_schedule: other_project_schedule) }

        it 'raises an error' do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:oncall_schedule_id]).to eq ['Schedule must be from the same project as the policy']
        end
      end
    end
  end
end
