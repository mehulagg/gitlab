# frozen_string_literal: true

# Used to find and remove all billable Member records (GroupMember or ProjectMember)
# within a group's hierarchy for the given user_id, so that a billable member can be completely
# removed from the group and it's subgroups and projects
#
# Ex.
#   BillableMembers::Destroy.new(group, user_id: 1, current_user: current_user).execute
#
module BillableMembers
  class DestroyService
    include BaseServiceUtility

    InvalidGroupError = Class.new(StandardError)
    InvalidMemberError = Class.new(StandardError)

    def initialize(group, user_id:, current_user:)
      @group = group
      @user_id = user_id
      @current_user = current_user
    end

    def execute
      check_group_level
      check_user_access

      remove_user_from_resources

      success
    rescue InvalidGroupError, InvalidMemberError, Gitlab::Access::AccessDeniedError => e
      error(e.message)
    end

    private

    attr_reader :group, :user_id, :current_user

    # rubocop: disable CodeReuse/ActiveRecord
    def remove_user_from_resources
      memberships_found = false
      memberships = ::Member.in_hierarchy(group).where(user_id: user_id)

      memberships.find_each do |member|
        memberships_found = true
        ::Members::DestroyService.new(current_user).execute(member, skip_subresources: true)
      end

      raise InvalidMemberError, 'No member found for the given user_id' unless memberships_found
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def check_group_level
      unless group.root?
        raise InvalidGroupError, 'Invalid group provided, must be top-level'
      end
    end

    def check_user_access
      unless can?(current_user, :admin_group_member, group)
        raise Gitlab::Access::AccessDeniedError, 'User unauthorized to remove member'
      end
    end
  end
end
