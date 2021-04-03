# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupMembersFinder do
  subject(:finder) { described_class.new(group) }

  let_it_be(:group) { create :group }

  let_it_be(:non_owner_access_level) { Gitlab::Access.options.values.sample }
  let_it_be(:group_owner_membership) { group.add_user(create(:user), Gitlab::Access::OWNER) }
  let_it_be(:group_member_membership) { group.add_user(create(:user), non_owner_access_level) }
  let_it_be(:dedicated_member_account_membership) do
    group.add_user(create(:user, managing_group: group), non_owner_access_level)
  end

  describe '#not_managed' do
    it 'returns non-owners without group managed accounts' do
      expect(finder.not_managed).to eq([group_member_membership])
    end
  end

  describe '#execute' do
    let_it_be(:group_minimal_access_membership) do
      create(:group_member, :minimal_access, source: group, user: create(:user))
    end

    context 'when group does not allow minimal access members' do
      before do
        stub_licensed_features(minimal_access_role: false)
      end

      it 'returns only members with full access' do
        result = finder.execute(include_relations: [:direct, :descendants])

        expect(result.to_a).to match_array([group_owner_membership, group_member_membership, dedicated_member_account_membership])
      end
    end

    context 'when group allows minimal access members' do
      before do
        group.clear_memoization(:feature_available)
        stub_licensed_features(minimal_access_role: true)
      end

      it 'also returns members with minimal access' do
        result = finder.execute(include_relations: [:direct, :descendants])

        expect(result.to_a).to match_array([group_owner_membership, group_member_membership, dedicated_member_account_membership, group_minimal_access_membership])
      end
    end
  end
end
