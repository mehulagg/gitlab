# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::OrchestrationPolicyRuleSchedule do
  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User') }
    it { is_expected.to belong_to(:security_orchestration_policy_configuration).class_name('Security::OrchestrationPolicyConfiguration') }
  end

  describe 'validations' do
    subject { create(:security_orchestration_policy_rule_schedule) }

    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_presence_of(:security_orchestration_policy_configuration) }
    it { is_expected.to validate_presence_of(:cron) }
    it { is_expected.to validate_presence_of(:policy_index) }
  end
end
