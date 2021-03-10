# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallSchedules::UpdateService do
  let_it_be(:user_with_permissions) { create(:user) }
  let_it_be(:user_without_permissions) { create(:user) }
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be_with_reload(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }

  let(:current_user) { user_with_permissions }
  let(:params) { { name: 'Updated name', description: 'Updated description', timezone: 'America/New_York' } }
  let(:service) { described_class.new(oncall_schedule, current_user, params) }

  before do
    stub_licensed_features(oncall_schedules: true)
    project.add_maintainer(user_with_permissions)
  end

  describe '#execute' do
    shared_examples 'error response' do |message|
      it 'has an informative message' do
        expect(execute).to be_error
        expect(execute.message).to eq(message)
      end
    end

    subject(:execute) { service.execute }

    context 'when the current_user is anonymous' do
      let(:current_user) { nil }

      it_behaves_like 'error response', 'You have insufficient permissions to update an on-call schedule for this project'
    end

    context 'when the current_user does not have permissions to update on-call schedules' do
      let(:current_user) { user_without_permissions }

      it_behaves_like 'error response', 'You have insufficient permissions to update an on-call schedule for this project'
    end

    context 'when feature is not available' do
      before do
        stub_licensed_features(oncall_schedules: false)
      end

      it_behaves_like 'error response', 'Your license does not support on-call schedules'
    end

    context 'when an on-call schedule witht the same name already exists' do
      before do
        create(:incident_management_oncall_schedule, project: project, name: params[:name])
      end

      it_behaves_like 'error response', 'Name has already been taken'
    end

    context 'with valid params' do
      it 'successfully creates an on-call schedule' do
        response = execute
        payload = response.payload
        oncall_schedule.reload

        expect(response).to be_success
        expect(payload[:oncall_schedule]).to eq(oncall_schedule)
        expect(oncall_schedule).to be_a(::IncidentManagement::OncallSchedule)
        expect(oncall_schedule.name).to eq(params[:name])
        expect(oncall_schedule.description).to eq(params[:description])
        expect(oncall_schedule.timezone).to eq(params[:timezone])
      end
    end
  end
end
