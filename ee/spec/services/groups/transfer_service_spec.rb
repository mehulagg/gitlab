# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::TransferService, '#execute' do
  let(:user) { create(:user) }
  let(:group) { create(:group, :public) }
  let(:project) { create(:project, :public, namespace: group) }
  let(:new_group) { create(:group, :public) }
  let(:transfer_service) { described_class.new(group, user) }

  before do
    group.add_owner(user)
    new_group&.add_owner(user)
  end

  context 'when visibility changes' do
    let(:new_group) { create(:group, :private) }

    before do
      stub_ee_application_setting(elasticsearch_indexing: true)
    end

    it 'reindexes projects', :elastic do
      project1 = create(:project, :repository, :public, namespace: group)
      project2 = create(:project, :repository, :public, namespace: group)
      project3 = create(:project, :repository, :private, namespace: group)

      expect(Elastic::ProcessBookkeepingService).to receive(:track!).with(project1)
      expect(Elastic::ProcessBookkeepingService).to receive(:track!).with(project2)
      expect(Elastic::ProcessBookkeepingService).not_to receive(:track!).with(project3)

      transfer_service.execute(new_group)

      expect(transfer_service.error).not_to be
      expect(group.parent).to eq(new_group)
    end
  end

  context 'with epics' do
    context 'when epics feature is disabled' do
      it 'transfers a group successfully' do
        transfer_service.execute(new_group)

        expect(group.parent).to eq(new_group)
      end
    end

    context 'when epics feature is enabled' do
      let(:root_group) { create(:group) }
      let(:subgroup_group_level_1) { create(:group, parent: root_group) }
      let(:subgroup_group_level_2) { create(:group, parent: subgroup_group_level_1) }
      let(:subgroup_group_level_3) { create(:group, parent: subgroup_group_level_2) }

      let!(:root_epic) { create(:epic, group: root_group) }
      let!(:level_1_epic_1) { create(:epic, group: subgroup_group_level_1, parent: root_epic) }
      let!(:level_1_epic_2) { create(:epic, group: subgroup_group_level_1, parent: level_1_epic_1) }
      let!(:level_2_epic_1) { create(:epic, group: subgroup_group_level_2, parent: root_epic) }
      let!(:level_2_epic_2) { create(:epic, group: subgroup_group_level_2, parent: level_1_epic_1) }
      let!(:level_2_subepic) { create(:epic, group: subgroup_group_level_2, parent: level_2_epic_2) }
      let!(:level_3_epic) { create(:epic, group: subgroup_group_level_3, parent: level_2_epic_2) }

      before do
        root_group.add_owner(user)

        stub_licensed_features(epics: true)
      end

      context 'when group is moved completely out of the main group' do
        let(:group) { subgroup_group_level_1 }

        before do
          transfer_service.execute(new_group)
        end

        it 'keeps relations between epics in the group structure' do
          expect(level_1_epic_2.reload.parent).to eq(level_1_epic_1)
          expect(level_2_epic_2.reload.parent).to eq(level_1_epic_1)
          expect(level_2_subepic.reload.parent).to eq(level_2_epic_2)
          expect(level_3_epic.reload.parent).to eq(level_2_epic_2)
        end

        it 'removes relations to epics of the old parent group' do
          expect(level_1_epic_1.reload.parent).to be_nil
          expect(level_2_epic_1.reload.parent).to be_nil
        end
      end

      context 'when group is moved some levels up' do
        let(:group) { subgroup_group_level_2 }

        before do
          transfer_service.execute(root_group)
        end

        it 'keeps relations between epics in the group structure' do
          expect(level_1_epic_1.reload.parent).to eq(root_epic)
          expect(level_1_epic_2.reload.parent).to eq(level_1_epic_1)
          expect(level_2_epic_1.reload.parent).to eq(root_epic)
          expect(level_2_subepic.reload.parent).to eq(level_2_epic_2)
          expect(level_3_epic.reload.parent).to eq(level_2_epic_2)
        end

        it 'removes relations to epics of the old parent group' do
          expect(level_2_epic_2.reload.parent).to be_nil
        end
      end
    end
  end
end
