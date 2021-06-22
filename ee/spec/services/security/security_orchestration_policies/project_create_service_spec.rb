# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::SecurityOrchestrationPolicies::ProjectCreateService do
  describe '#execute' do
    let_it_be(:project) { create(:project) }
    let_it_be(:current_user) { project.owner }

    subject(:service) { described_class.new(project: project, current_user: current_user) }

    context 'when security_orchestration_policies_configuration does not exist for project' do
      let_it_be(:maintainer) { create(:user) }

      before do
        project.add_maintainer(maintainer)
      end

      it 'creates new project' do
        response = service.execute

        policy_project = response[:policy_project]
        expect(project.security_orchestration_policy_configuration.security_policy_management_project).to eq(policy_project)
        expect(policy_project.namespace).to eq(project.namespace)
        expect(policy_project.team.developers).to contain_exactly(maintainer)
      end
    end

    context 'when project creation fails' do
      let_it_be(:project) { create(:project) }
      let_it_be(:current_user) { create(:user) }

      it 'returns error' do
        response = service.execute

        expect(response[:status]).to eq(:error)
        expect(response[:message]).to eq('Namespace is not valid')
      end
    end

    context 'when security_orchestration_policies_configuration already exists for project' do
      let_it_be(:policy_configuration) { create(:security_orchestration_policy_configuration, project: project) }

      it 'returns error' do
        response = service.execute

        expect(response[:status]).to eq(:error)
        expect(response[:message]).to eq('Security Policy project already exists.')
      end
    end
  end
end
