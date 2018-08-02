# frozen_string_literal: true

module Members
  class DestroyService < Members::BaseService
    prepend EE::Members::DestroyService

    def execute(member, skip_authorization: false)
      raise Gitlab::Access::AccessDeniedError unless skip_authorization || can_destroy_member?(member)

      return member if member.is_a?(GroupMember) && member.source.last_owner?(member.user)

      member.destroy

      member.user&.invalidate_cache_counts

      if member.request? && member.user != current_user
        notification_service.decline_access_request(member)
      end

      enqeue_delete_todos(member)

      after_execute(member: member)

      member
    end

    private

    def enqeue_delete_todos(member)
      type = member.is_a?(GroupMember) ? 'Group' : 'Project'
      # don't enqueue immediately to prevent todos removal in case of a mistake
      TodosDestroyer::EntityLeaveWorker.perform_in(1.hour, member.user_id, member.source_id, type)
    end

    def can_destroy_member?(member)
      can?(current_user, destroy_member_permission(member), member)
    end

    def destroy_member_permission(member)
      case member
      when GroupMember
        :destroy_group_member
      when ProjectMember
        :destroy_project_member
      else
        raise "Unknown member type: #{member}!"
      end
    end
  end
end
