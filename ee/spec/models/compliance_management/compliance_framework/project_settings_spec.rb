# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::ProjectSettings do
  let_it_be(:group) { create(:group) }
  let_it_be(:sub_group) { create(:group, parent: group) }
  let_it_be(:project) { create(:project, group: sub_group) }

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
  end

  describe 'creation of ComplianceManagement::Framework record' do
    subject { create(:compliance_framework_project_setting, :sox, project: project) }

    it 'creates a new record' do
      expect(subject.reload.compliance_management_framework.name).to eq('SOX')
    end
  end

  describe 'set a custom ComplianceManagement::Framework' do
    let(:framework) { create(:compliance_framework, name: 'my framework') }

    it 'assigns the framework' do
      subject.compliance_management_framework = framework
      subject.save!

      expect(subject.compliance_management_framework.name).to eq('my framework')
    end
  end
end
