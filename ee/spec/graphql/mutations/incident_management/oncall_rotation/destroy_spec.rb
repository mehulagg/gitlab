# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::IncidentManagement::OncallRotation::Destroy do
  let_it_be(:current_user) { create(:user) }
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:rotation) { create(:incident_management_oncall_rotation, schedule: schedule) }

  let(:args) do
    {
      project_path: project.full_path,
      schedule_iid: schedule.iid,
      id: rotation.to_global_id
    }
  end

  describe '#resolve' do
    subject(:resolve) { mutation_for(project, current_user).resolve(**args) }

    context 'user has access to project' do
      before do
        stub_licensed_features(oncall_schedules: true)
      end

      before_all do
        project.add_maintainer(current_user)
      end

      context 'when OncallRotation::DestroyService responds with success' do
        it 'returns the on-call rotation with no errors' do
          expect(resolve).to match(
            oncall_rotation: rotation,
            errors: be_empty
          )
        end

        it 'removes the rotation' do
          resolve

          expect { rotation.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when OncallRotations::DestroyService responds with an error' do
        before do
          allow_next_instance_of(::IncidentManagement::OncallRotations::DestroyService) do |service|
            allow(service).to receive(:execute)
              .and_return(ServiceResponse.error(payload: { oncall_rotation: nil }, message: 'An error occurred'))
          end
        end

        it 'returns errors' do
          expect(resolve).to eq(
            oncall_rotation: nil,
            errors: ['An error occurred']
          )
        end
      end

      describe 'error cases' do
        context 'project path incorrect' do
          before do
            args[:project_path] = "something/incorrect"
          end

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
          end
        end

        context 'license disabled' do
          before do
            stub_licensed_features(oncall_schedules: false)
          end

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
          end
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
