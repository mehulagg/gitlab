# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Orchestration::AssignService do
  let_it_be(:project) { create(:project) }
  let_it_be(:policy_project) { create(:project) }
  let_it_be(:new_policy_project) { create(:project) }

  describe '#execute' do
    subject(:service) { described_class.new(project, nil, policy_project_id: policy_project.id).execute }

    it 'assings policy project to project' do
      expect(service).to be_success
      expect(project.security_orchestration_policy_configuration.security_policy_management_project_id).to eq(policy_project.id)
    end

    it 'updates project with new policy project' do
      repeated_service = described_class.new(project, nil, policy_project_id: new_policy_project.id).execute

      expect(repeated_service).to be_success
      expect(project.security_orchestration_policy_configuration.security_policy_management_project_id).to eq(new_policy_project.id)
    end


    describe 'with invalid project id' do
      subject(:service) { described_class.new(project, nil, policy_project_id: 345).execute }

      it 'assings policy project to project' do
        expect(service).to be_error

        expect { service }.not_to change { project.security_orchestration_policy_configuration }
      end
    end
  end
end