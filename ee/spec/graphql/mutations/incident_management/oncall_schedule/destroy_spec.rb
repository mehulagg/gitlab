# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::IncidentManagement::OncallSchedule::Destroy do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }
  let(:args) { { project_path: project.full_path, iid: oncall_schedule.iid.to_s } }

  specify { expect(described_class).to require_graphql_authorizations(:admin_incident_management_oncall_schedule) }

  before do
    stub_licensed_features(oncall_schedules: true)
  end

  describe '#resolve' do
    subject(:resolve) { mutation_for(project, current_user).resolve(**args) }

    context 'user has access to project' do
      before do
        project.add_maintainer(current_user)
      end

      context 'when OncallSchedules::DestroyService responds with success' do
        it 'returns the on-call schedule with no errors' do
          expect(resolve).to eq(
            oncall_schedule: oncall_schedule,
            errors: []
          )
        end
      end

      context 'when OncallSchedules::DestroyService responds with an error' do
        before do
          allow_any_instance_of(::IncidentManagement::OncallSchedules::DestroyService)
            .to receive(:execute)
            .and_return(ServiceResponse.error(payload: { oncall_schedule: nil }, message: 'An error has occurred'))
        end

        it 'returns errors' do
          expect(resolve).to eq(
            oncall_schedule: nil,
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
