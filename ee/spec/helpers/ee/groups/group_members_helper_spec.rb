# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groups::GroupMembersHelper do
  include MembersPresentation

  let_it_be(:group) { create(:group) }
  let_it_be(:current_user) { create(:user) }

  before do
    allow(helper).to receive(:current_user).and_return(current_user)
  end

  describe '.group_member_select_options' do
    before do
      helper.instance_variable_set(:@group, group)
    end

    it 'returns an options hash with skip_ldap' do
      expect(helper.group_member_select_options).to include(skip_ldap: false)
    end
  end

  describe '#members_data' do
    let(:group_member) { create(:group_member, group: group, created_by: current_user) }

    subject { helper.send('members_data', group, present_members([group_member])) }

    before do
      allow(helper).to receive(:can?).with(current_user, :owner_access, group).and_return(true)
    end

    it 'adds `using_license` property to hash' do
      allow(group_member.user).to receive(:using_gitlab_com_seat?).with(group).and_return(true)

      expect(subject.first).to include(using_license: true)
    end

    it 'adds `group_sso` property to hash' do
      allow(group_member.user).to receive(:group_sso?).with(group).and_return(true)

      expect(subject.first).to include(group_sso: true)
    end

    it 'adds `group_managed_account` property to hash' do
      allow(group_member.user).to receive(:group_managed_account?).and_return(true)

      expect(subject.first).to include(group_managed_account: true)
    end
  end

  describe '#group_members_list_data_attributes' do
    before do
      allow(helper).to receive(:override_group_group_member_path).with(group, ':id').and_return('/groups/foo-bar/-/group_members/:id/override')
      allow(helper).to receive(:group_group_member_path).with(group, ':id').and_return('/groups/foo-bar/-/group_members/:id')
      allow(helper).to receive(:can?).with(current_user, :admin_group_member, group).and_return(true)
    end

    it 'adds `ldap_override_path` to returned hash' do
      expect(helper.group_members_list_data_attributes(group, {})).to include(ldap_override_path: '/groups/foo-bar/-/group_members/:id/override')
    end
  end
end
