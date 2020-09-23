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
end
