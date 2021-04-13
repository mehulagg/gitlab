# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallSchedulesFinder do
  let_it_be(:current_user) { create(:user) }
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:another_oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:oncall_schedule_from_another_project) { create(:incident_management_oncall_schedule) }

  let(:params) { {} }

  describe '#execute' do
    subject(:execute) { described_class.new(current_user, project, params).execute }

    context 'when feature is available' do
      before do
        stub_licensed_features(oncall_schedules: true)
      end

      context 'when user has permissions' do
        before do
          project.add_maintainer(current_user)
        end

        it 'returns project on-call schedules' do
          is_expected.to contain_exactly(oncall_schedule, another_oncall_schedule)
        end

        context 'when iid given' do
          let(:params) { { iid: oncall_schedule.iid } }

          it 'returns an on-call schedule for iid' do
            is_expected.to contain_exactly(oncall_schedule)
          end
        end
      end

      context 'when user has no permissions' do
        it { is_expected.to eq(IncidentManagement::OncallSchedule.none) }
      end
    end

    context 'when feature is not avaiable' do
      before do
        stub_licensed_features(oncall_schedules: false)
      end

      it { is_expected.to eq(IncidentManagement::OncallSchedule.none) }
    end
  end
end
