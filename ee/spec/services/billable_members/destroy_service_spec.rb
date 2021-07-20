# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BillableMembers::DestroyService do
  describe '#execute' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:root_group) { create(:group) }

    let(:group) { root_group }

    let(:user_id) { nil }

    subject(:execute) { described_class.new(group, user_id: user_id, current_user: current_user).execute }

    context 'when unauthorized' do
      it 'raises an access error' do
        result = execute

        expect(result[:status]).to eq :error
        expect(result[:message]).to eq 'User unauthorized to remove member'
      end
    end

    context 'when authorized' do
      let(:subgroup) { create(:group, parent: root_group) }
      let(:project_1) { create(:project, group: subgroup) }
      let(:project_2) { create(:project, group: root_group) }

      let(:group_member) { create(:group_member, group: root_group) }
      let(:subgroup_member) { create(:group_member, group: subgroup) }
      let(:project_member) { create(:project_member, project: project_1) }

      before do
        group.add_owner(current_user)
      end

      context 'when passing a sub group to the service' do
        let(:group) { subgroup }

        it 'raises an invalid group error' do
          result = execute

          expect(result[:status]).to eq :error
          expect(result[:message]).to eq 'Invalid group provided, must be top-level'
        end
      end

      context 'when removing a group member' do
        let(:user_id) { group_member.user_id }

        it 'removes the member' do
          execute

          expect(root_group.members).not_to include(group_member)
        end
      end

      context 'when removing a subgroup member' do
        let(:user_id) { subgroup_member.user_id }

        it 'removes the member' do
          execute

          expect(subgroup.members).not_to include(subgroup_member)
        end
      end

      context 'when removing a project member' do
        let(:user_id) { project_member.user_id }

        it 'removes the member' do
          execute

          expect(project_1.members).not_to include(project_member)
        end
      end

      context 'when the user is a direct member of multiple projects' do
        let(:multi_project_user) { create(:user) }
        let(:user_id) { multi_project_user.id }

        it 'removes the user from all the projects' do
          project_1.add_developer(multi_project_user)
          project_2.add_developer(multi_project_user)

          execute

          expect(multi_project_user.projects).not_to include(project_1)
          expect(multi_project_user.projects).not_to include(project_2)
        end
      end

      context 'when the user has no Member record' do
        let(:non_member) { create(:user) }
        let(:user_id) { non_member.id }

        it 'returns an appropriate error' do
          result = execute

          expect(result[:status]).to eq :error
          expect(result[:message]).to eq 'No member found for the given user_id'
        end
      end
    end
  end
end
