# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Disallow2FAForSubgroupsWorker do
  let_it_be(:group) { create(:group, require_two_factor_authentication: true) }
  let_it_be(:subgroup) { create(:group, parent: group, require_two_factor_authentication: true) }
  let_it_be(:user) { create(:user, :two_factor, require_two_factor_authentication_from_group: true) }
  let_it_be(:user_for_subgroup) { create(:user, :two_factor, require_two_factor_authentication_from_group: true) }

  it "updates group" do
    described_class.new.perform(group.id)

    expect(group.reload.require_two_factor_authentication).to eq(false)
  end

  it "updates group members" do
    group.add_user(user, GroupMember::DEVELOPER)
    binding.pry
    described_class.new.perform(group.id)

    expect(user.reload.require_two_factor_authentication_from_group).to eq(false)
  end

  it "updates descendant members" do
    subgroup.add_user(user_for_subgroup, GroupMember::DEVELOPER)

    described_class.new.perform(group.id)

    expect(user_for_subgroup.reload.require_two_factor_authentication_from_group).to eq(false)
  end
end
