# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotationsFinder do
  let_it_be(:current_user) { create(:user) }
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:another_oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }

  let_it_be(:schedule_rotation_1) { create(:incident_management_oncall_rotation, schedule: oncall_schedule) }
  let_it_be(:schedule_rotation_2) { create(:incident_management_oncall_rotation, schedule: oncall_schedule) }
  let_it_be(:other_schedule_rotation) { create(:incident_management_oncall_rotation, schedule: another_oncall_schedule) }

  let(:params) { {} }

  describe '#execute' do
    subject(:execute) { described_class.new(current_user, project, oncall_schedule, params).execute }

    context 'when feature is available' do
      before do
        stub_licensed_features(oncall_schedules: true)
      end

      context 'when user has permissions' do
        before_all do
          project.add_maintainer(current_user)
        end

        it 'returns project on-call rotations' do
          is_expected.to contain_exactly(schedule_rotation_1, schedule_rotation_2)
        end

        context 'when id given' do
          let(:params) { { id: schedule_rotation_1.id } }

          it 'returns an on-call rotation for id' do
            is_expected.to contain_exactly(schedule_rotation_1)
          end
        end

        context 'schedule is nil' do
          let(:oncall_schedule) { nil }

          it { is_expected.to eq(IncidentManagement::OncallRotation.none) }
        end
      end

      context 'when user has no permissions' do
        it { is_expected.to eq(IncidentManagement::OncallRotation.none) }
      end
    end

    context 'when feature is not available' do
      before do
        stub_licensed_features(oncall_schedules: false)
      end

      it { is_expected.to eq(IncidentManagement::OncallRotation.none) }
    end
  end
end
