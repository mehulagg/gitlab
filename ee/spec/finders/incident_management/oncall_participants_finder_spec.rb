# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallParticipantsFinder do
  let_it_be(:current_user) { create(:user) }
  let_it_be_with_refind(:project) { create(:project) }

  let_it_be(:s1) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:s1_r1) { create(:incident_management_oncall_rotation, :with_participant, schedule: s1) }
  let_it_be(:s1_r1_p1) { s1_r1.participants.first }
  let_it_be(:s1_r1_shift1) { create(:incident_management_oncall_shift, participant: s1_r1_p1) }

  let_it_be(:s1_r2) { create(:incident_management_oncall_rotation, :with_participant, schedule: s1) }
  let_it_be(:s1_r2_p1) { s1_r2.participants.first }
  let_it_be(:s1_r2_shift1) { create(:incident_management_oncall_shift, participant: s1_r2_p1) }
  let_it_be(:s1_r2_p2) { create(:incident_management_oncall_participant, rotation: s1_r2) }
  let_it_be(:s1_r2_shift2) { create(:incident_management_oncall_shift, participant: s1_r2_p2, starts_at: s1_r2_shift1.ends_at) }

  let_it_be(:s2) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:s2_r1) { create(:incident_management_oncall_rotation, :with_participant, schedule: s2) }
  let_it_be(:s2_r1_p1) { s2_r1.participants.first }
  let_it_be(:s2_r1_shift1) { create(:incident_management_oncall_shift, participant: s2_r1_p1) }
  # Rotation without participants
  let_it_be(:s2_r2) { create(:incident_management_oncall_rotation, schedule: s2) }

  # Schedules on another project
  let_it_be(:proj2_s1_r1_p1) { create(:incident_management_oncall_participant) }
  let_it_be(:proj2_s1_r1_shift1) { create(:incident_management_oncall_shift, participant: proj2_s1_r1_p1) }
  let_it_be(:proj2_s1_r1) { proj2_s1_r1_p1.rotation }

  # This participant is the same user as participant in s1_r2_p1
  let_it_be(:proj2_s1_r1_p2) { create(:incident_management_oncall_participant, user: s1_r2_p1.user, rotation: proj2_s1_r1) }
  let_it_be(:proj2_s1_r1_shift2) { create(:incident_management_oncall_shift, participant: proj2_s1_r1_p2, starts_at: proj2_s1_r1_shift1.ends_at) }

  let(:params) { {} }

  describe '#execute' do
    subject(:execute) { described_class.new(project, params).execute }

    context 'when feature is available' do
      before do
        stub_licensed_features(oncall_schedules: true)
      end

      context 'without parameters' do
        it { is_expected.to contain_exactly(s1_r1_p1, s1_r2_p1, s1_r2_p2, s2_r1_p1) }
      end

      context 'with :oncall_at parameter specified' do
        let(:during_first_shift) { Time.current }
        let(:during_second_shift) { s1_r2_shift2.starts_at + 5.minutes }
        let(:after_second_shift) { s1_r2_shift2.ends_at + 5.minutes }
        let(:before_shifts) { s1_r1.starts_at - 15.minutes }

        context 'with all persisted shifts for oncall_at time' do
          let(:params) { { oncall_at: during_first_shift } }

          it { is_expected.to contain_exactly(s1_r1_p1, s1_r2_p1, s2_r1_p1) }

          it 'does not attempt to generate shifts' do
            expect(IncidentManagement::OncallShiftGenerator).not_to receive(:new)

            execute
          end
        end

        context 'with some persisted shifts for oncall_at time' do
          let(:params) { { oncall_at: during_second_shift } }

          it { is_expected.to contain_exactly(s1_r1_p1, s1_r2_p2, s2_r1_p1) }

          it 'does not run additional queries for each persisted shift' do
            query_count = ActiveRecord::QueryRecorder.new { execute }

            create(:incident_management_oncall_shift, participant: s1_r1_p1, starts_at: s1_r1_shift1.ends_at)

            expect { described_class.new(project, params).execute }.not_to exceed_query_limit(query_count)
          end
        end

        context 'with no persisted shifts for oncall_at time' do
          let(:params) { { oncall_at: after_second_shift } }

          it { is_expected.to contain_exactly(s1_r1_p1, s1_r2_p1, s2_r1_p1) }
        end

        context 'before rotations have started' do
          let(:params) { { oncall_at: before_shifts } }

          it { is_expected.to be_empty }
        end

        it 'does not require additional queries to generate shifts' do
          query_count = ActiveRecord::QueryRecorder.new { described_class.new(project, oncall_at: during_first_shift).execute }

          expect { described_class.new(project, oncall_at: after_second_shift).execute }
            .not_to exceed_query_limit(query_count)
        end
      end
    end

    context 'when feature is not avaiable' do
      before do
        stub_licensed_features(oncall_schedules: false)
      end

      it { is_expected.to eq(IncidentManagement::OncallParticipant.none) }
    end
  end
end
