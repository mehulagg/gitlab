# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::IncidentManagement::EscalationPolicy::Destroy do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let(:escalation_policy) { create(:incident_management_escalation_policy, project: project) }
  let(:args) { { id: escalation_policy.to_global_id } }

  specify { expect(described_class).to require_graphql_authorizations(:admin_incident_management_escalation_policy) }

  before do
    stub_licensed_features(oncall_schedules: true, escalation_policies: true)
  end

  describe '#resolve' do
    subject(:resolve) { mutation_for(project, current_user).resolve(**args) }

    context 'user has access to project' do
      before do
        project.add_maintainer(current_user)
      end

      context 'when EscalationPolicies::DestroyService responds with success' do
        it 'returns the escalation policy with no errors' do
          expect(resolve).to eq(
            escalation_policy: escalation_policy,
            errors: []
          )
        end
      end

      context 'when EscalationPolicies::DestroyService responds with an error' do
        before do
          allow_next_instance_of(::IncidentManagement::EscalationPolicies::DestroyService) do |service|
            allow(service)
              .to receive(:execute)
              .and_return(ServiceResponse.error(payload: { escalation_policy: nil }, message: 'An error has occurred'))
          end
        end

        it 'returns errors' do
          expect(resolve).to eq(
            escalation_policy: nil,
            errors: ['An error has occurred']
          )
        end
      end
    end

    context 'when resource is not accessible to the user' do
      it 'raises an error' do
        expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end
  end

  private

  def mutation_for(project, user)
    described_class.new(object: project, context: { current_user: user }, field: nil)
  end
end
