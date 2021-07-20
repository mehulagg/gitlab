# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::MemberOncallRotationsFinder do
  let_it_be(:user) { create(:user) }

  describe '#execute' do
    subject(:execute) { described_class.new(member).execute }

    # 2 Group Projects
    let_it_be(:group) { create(:group) }

    let_it_be(:group_project) { create(:project, group: group) }
    let_it_be(:group_schedule) { create(:incident_management_oncall_schedule, project: group_project) }
    let_it_be(:group_rotation) { add_rotation_for_user(user, group_schedule) }

    let_it_be(:second_group_project) { create(:project, group: group) }
    let_it_be(:second_group_schedule) { create(:incident_management_oncall_schedule, project: second_group_project) }
    let_it_be(:second_group_project_user_rotation) { add_rotation_for_user(user, second_group_schedule) }
    let_it_be(:second_group_project_other_rotation) { create(:incident_management_oncall_rotation, schedule: second_group_schedule) }

    # 1 standalone Project
    let_it_be(:project) { create(:project) }
    let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
    let_it_be(:rotation) { add_rotation_for_user(user, schedule) }

    context 'group member' do
      let!(:member) { create(:group_member, source: group, user: user) }

      it 'returns the group rotations the user is in across many projects' do
        expect(execute).to contain_exactly(group_rotation, second_group_project_user_rotation)
      end
    end

    context 'project member' do
      # Member is project member
      let!(:member) { create(:project_member, source: project, user: user) }

      it "returns the rotations the user is in for the member's project" do
        expect(execute).to contain_exactly(rotation)
      end
    end
  end

  def add_rotation_for_user(user, schedule)
    rotation = create(:incident_management_oncall_rotation, schedule: schedule)
    create(:incident_management_oncall_participant, rotation: rotation, user: user)

    rotation
  end
end
