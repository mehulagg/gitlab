# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::SyncService, '#execute' do
  let(:user) { create(:user) }

  describe '#execute' do
    subject(:sync) { described_class.new(nil, user, group_links: group_links).execute }

    let_it_be(:top_level_group) { create(:group) }
    let_it_be(:group1) { create(:group, parent: top_level_group) }

    let_it_be(:group_links) do
      [
        create(:saml_group_link, group: top_level_group, access_level: 'Guest'),
        create(:saml_group_link, group: group1, access_level: 'Reporter'),
        create(:saml_group_link, group: group1, access_level: 'Developer')
      ]
    end

    it 'adds two new group member records' do
      expect { sync }.to change { GroupMember.count }.by(2)
    end

    it 'adds the user to top_level_group as Guest' do
      sync

      expect(top_level_group.members.find_by(user_id: user.id).access_level)
        .to eq(::Gitlab::Access::GUEST)
    end

    it 'adds the user to group1 as Developer' do
      sync

      expect(group1.members.find_by(user_id: user.id).access_level)
        .to eq(::Gitlab::Access::DEVELOPER)
    end

    context 'when the user is already a member' do
      context 'with the correct access level' do
        before do
          group1.add_user(user, ::Gitlab::Access::DEVELOPER)
        end

        it 'does not change group member count' do
          expect { sync }.not_to change { group1.members.count }
        end

        it 'retains the correct access level' do
          sync

          expect(group1.members.find_by(user_id: user.id).access_level)
            .to eq(::Gitlab::Access::DEVELOPER)
        end
      end

      context 'with a different access level' do
        before do
          top_level_group.add_user(user, ::Gitlab::Access::MAINTAINER)
        end

        it 'does not change the group member count' do
          expect { sync }.not_to change { top_level_group.members.count }
        end

        it 'updates the access_level' do
          sync

          expect(top_level_group.members.find_by(user_id: user.id).access_level)
            .to eq(::Gitlab::Access::GUEST)
        end
      end
    end
  end
end
