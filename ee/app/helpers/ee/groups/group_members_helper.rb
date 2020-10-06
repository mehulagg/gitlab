# frozen_string_literal: true

module EE::Groups::GroupMembersHelper
  extend ::Gitlab::Utils::Override

  override :group_member_select_options
  def group_member_select_options
    super.merge(skip_ldap: @group.ldap_synced?)
  end

  override :ldap_override_path
  def ldap_override_path(group)
    override_group_group_member_path(group, ':id')
  end

  private

  override :members_data
  def members_data(group, members)
    ce_members = super(group, members)

    members.map.with_index do |member, index|
      ce_members[index].merge({
        using_license: can?(current_user, :owner_access, group) && member.user&.using_gitlab_com_seat?(group),
        group_sso: member.user&.group_sso?(group),
        group_managed_account: member.user&.group_managed_account?,
        can_override: member.can_override?,
        is_overridden: member.override
      })
    end
  end
end
