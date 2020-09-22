# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::ProjectSettings do
  subject { build :compliance_framework_project_setting }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:compliance_management_framework) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:project) }
  end
end
