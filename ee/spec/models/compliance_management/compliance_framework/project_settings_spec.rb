# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::ProjectSettings do
  let(:known_frameworks) { ComplianceManagement::ComplianceFramework::ProjectSettings.frameworks.keys }

  subject { build :compliance_framework_project_setting }

  describe 'Associations' do
    it 'belongs to project' do
      expect(subject).to belong_to(:project)
    end
  end

  describe 'Validations' do
    it 'confirms the presence of project' do
      expect(subject).to validate_presence_of(:project)
    end

    it 'confirms that the framework is unique for the project' do
      expect(subject).to validate_uniqueness_of(:framework).scoped_to(:project_id).ignoring_case_sensitivity
    end

    it 'allows all known frameworks' do
      expect(subject).to allow_values(*known_frameworks).for(:framework)
    end

    it 'invalidates an unknown framework' do
      expect { build :compliance_framework_project_setting, framework: 'ABCDEFGH' }.to raise_error(ArgumentError).with_message(/is not a valid framework/)
    end
  end
end
