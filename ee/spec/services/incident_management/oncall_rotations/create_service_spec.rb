# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotations::CreateService do
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:user_with_permissions) { create(:user) }
  let_it_be(:user_without_permissions) { create(:user) }
  let_it_be(:current_user) { user_with_permissions }

  let(:participants) do
    [
      {
        user: current_user,
        color_palette: 'blue',
        color_weight: '500'
      }
    ]
  end

  let(:params) { { name: 'On-call rotation', starts_at: Time.current, length: '1', length_unit: 'days' }.merge(participants: participants) }
  let(:service) { described_class.new(schedule, project, current_user, params) }

  before_all do
    project.add_maintainer(user_with_permissions)
  end

  before do
    stub_licensed_features(oncall_schedules: true)
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

      it_behaves_like 'error response', 'You have insufficient permissions to create an on-call rotation for this project'
    end

    context 'when the current_user does not have permissions to create on-call schedules' do
      let(:current_user) { user_without_permissions }

      it_behaves_like 'error response', 'You have insufficient permissions to create an on-call rotation for this project'
    end

    context 'when feature is not available' do
      before do
        stub_licensed_features(oncall_schedules: false)
      end

      it_behaves_like 'error response', 'Your license does not support on-call rotations'
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(oncall_schedules_mvc: false)
      end

      it_behaves_like 'error response', 'Your license does not support on-call rotations'
    end

    context 'when an on-call rotation already exists' do
      let!(:oncall_schedule) { create(:incident_management_oncall_rotation, oncall_schedule: schedule, name: 'On-call rotation') }

      it_behaves_like 'error response', 'Name has already been taken'
    end

    context 'with valid params' do
      it 'successfully creates an on-call rotation' do
        expect(execute).to be_success

        oncall_schedule = execute.payload[:oncall_rotation]
        expect(oncall_schedule).to be_a(::IncidentManagement::OncallRotation)
        expect(oncall_schedule.name).to eq('On-call rotation')
        expect(oncall_schedule.length).to eq(1)
        expect(oncall_schedule.length_unit).to eq('days')
      end
    end
  end
end
