# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::IncidentManagement::OncallSchedule::Create do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let(:args) do
    {
      project_path: project.full_path,
      name: 'On-call schedule',
      description: 'On-call schedule description',
      timezone: 'Europe/Berlin'
    }
  end

  specify { expect(described_class).to require_graphql_authorizations(:admin_incident_management_oncall_schedule) }

  describe '#resolve' do
    subject(:resolve) { mutation_for(project, current_user).resolve(args) }

    context 'user has access to project' do
      before do
        stub_licensed_features(oncall_schedules: true)
        project.add_maintainer(current_user)
      end

      context 'when OncallSchedules::CreateService responds with success' do
        it 'returns the on-call schedule with no errors' do
          expect(resolve).to eq(
            oncall_schedule: ::IncidentManagement::OncallSchedule.last,
            errors: []
          )
        end
      end

      context 'when OncallSchedules::CreateService responds with an error' do
        before do
          allow_any_instance_of(::IncidentManagement::OncallSchedules::CreateService)
            .to receive(:execute)
            .and_return(ServiceResponse.error(payload: { oncall_schedule: nil }, message: 'An on-call schedule already exists'))
        end

        it 'returns errors' do
          expect(resolve).to eq(
            oncall_schedule: nil,
            errors: ['An on-call schedule already exists']
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
