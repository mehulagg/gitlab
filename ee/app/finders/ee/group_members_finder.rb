# frozen_string_literal: true

module EE::GroupMembersFinder
  extend ActiveSupport::Concern
  extend ::Gitlab::Utils::Override

  prepended do
    attr_reader :group
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def not_managed
    group.group_members.non_owners.joins(:user).merge(User.not_managed(group: group))
  end
  # rubocop: enable CodeReuse/ActiveRecord

  override :group_members_list
  def group_members_list
    return group.all_group_members if group.minimal_access_role_allowed?

    super
  end

  override :all_group_members
  def all_group_members(groups)
    return members_of_groups(groups) if group.minimal_access_role_allowed?

    super
  end
end
