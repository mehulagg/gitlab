# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::ProjectSettings do
  let_it_be(:group) { create(:group) }
  let_it_be(:sub_group) { create(:group, parent: group) }
  let_it_be(:project) { create(:project, group: sub_group) }

  let(:known_frameworks) { ComplianceManagement::ComplianceFramework::ProjectSettings.frameworks.keys }

  subject { build(:compliance_framework_project_setting, project: project) }

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

  describe 'creation of ComplianceManagement::Framework record' do
    subject { create(:compliance_framework_project_setting, :sox, project: project) }

    it 'creates a new record' do
      expect(subject.reload.compliance_management_framework.name).to eq('SOX')
    end

    context 'when the framework record already exists for the group' do
      let!(:existing_compliance_framework) { group.compliance_management_frameworks.create!(name: 'SOX', description: 'does not matter', color: '#004494') }

      it 'creates a new record' do
        expect(subject.reload.compliance_management_framework).to eq(existing_compliance_framework)
      end
    end
  end
end
