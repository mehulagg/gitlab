# frozen_string_literal: true

module Groups
  module GroupLinks
    class CreateService < Groups::BaseService
      def execute(shared_group)
        unless group && shared_group &&
               can?(current_user, :admin_group_member, shared_group) &&
               can?(current_user, :read_group, group) &&
               sharing_allowed?(shared_group, group)
          return error('Not Found', 404)
        end

        link = GroupGroupLink.new(
          shared_group: shared_group,
          shared_with_group: group,
          group_access: params[:shared_group_access],
          expires_at: params[:expires_at]
        )

        if link.save
          group.refresh_members_authorized_projects(direct_members_only: true)
          success(link: link)
        else
          error(link.errors.full_messages.to_sentence, 409)
        end
      end

      private

      def sharing_allowed?(shared_group, group)
        sharing_outside_hierarchy_allowed?(shared_group) || within_hierarchy?(shared_group, group)
      end

      def sharing_outside_hierarchy_allowed?(shared_group)
        !shared_group.root_ancestor.namespace_settings.prevent_sharing_groups_outside_hierarchy
      end

      def within_hierarchy?(shared_group, group)
        shared_group.root_ancestor.self_and_descendants_ids.include?(group.id)
      end
    end
  end
end
