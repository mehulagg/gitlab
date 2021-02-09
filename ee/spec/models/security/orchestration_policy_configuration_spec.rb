# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::OrchestrationPolicyConfiguration do
  describe 'associations' do
    it { is_expected.to belong_to(:project).inverse_of(:security_orchestration_policy_configuration) }
    it { is_expected.to belong_to(:security_policy_management_project).class_name('Project') }
  end

  describe 'validations' do
    subject { create(:security_orchestration_policy_configuration) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:security_policy_management_project) }

    it { is_expected.to validate_uniqueness_of(:project) }
    it { is_expected.to validate_uniqueness_of(:security_policy_management_project) }
  end
end
