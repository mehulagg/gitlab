# frozen_string_literal: true

module Members
  class DestroyService < Members::BaseService
    def execute(member, skip_authorization: false, skip_subresources: false, unassign_issuables: false, destroy_bot: false)
      raise Gitlab::Access::AccessDeniedError unless skip_authorization || authorized?(member, destroy_bot)

      @skip_auth = skip_authorization

      return member if member.is_a?(GroupMember) && member.source.last_owner?(member.user)

      member.destroy

      member.user&.invalidate_cache_counts

      if member.request? && member.user != current_user
        notification_service.decline_access_request(member)
      end

      delete_subresources(member) unless skip_subresources
      enqueue_delete_todos(member)
      enqueue_unassign_issuables(member) if unassign_issuables

      after_execute(member: member)

      member
    end

    private

    def authorized?(member, destroy_bot)
      return can_destroy_bot_member?(member) if destroy_bot

      can_destroy_member?(member)
    end

    def delete_subresources(member)
      return unless member.is_a?(GroupMember) && member.user && member.group

      delete_project_members(member)
      delete_subgroup_members(member)
    end

    def delete_project_members(member)
      groups = member.group.self_and_descendants

      ProjectMember.in_namespaces(groups).with_user(member.user).each do |project_member|
        self.class.new(current_user).execute(project_member, skip_authorization: @skip_auth)
      end
    end

    def delete_subgroup_members(member)
      groups = member.group.descendants

      GroupMember.of_groups(groups).with_user(member.user).each do |group_member|
        self.class.new(current_user).execute(group_member, skip_authorization: @skip_auth, skip_subresources: true)
      end
    end

    def can_destroy_member?(member)
      can?(current_user, destroy_member_permission(member), member)
    end

    def can_destroy_bot_member?(member)
      can?(current_user, destroy_bot_member_permission(member), member)
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

    def destroy_bot_member_permission(member)
      raise "Unsupported bot member type: #{member}" unless member.is_a?(ProjectMember)

      :destroy_project_bot_member
    end

    def enqueue_unassign_issuables(member)
      source_type = member.is_a?(GroupMember) ? 'Group' : 'Project'

      member.run_after_commit_or_now do
        MembersDestroyer::UnassignIssuablesWorker.perform_async(member.user_id, member.source_id, source_type)
      end
    end
  end
end

Members::DestroyService.prepend_if_ee('EE::Members::DestroyService')
