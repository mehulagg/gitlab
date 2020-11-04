# frozen_string_literal: true

#
# Usage example:
#
# Groups::SyncService.new(top_level_group, user, group_links: array_of_group_links).execute
#
# Given group links must respond to `group_id` and `access_level`.
#
# This is a generic group sync service, reusable by many IdP-specific
# implementations. The worker (caller) is responsible for providing the
# specific group links, which this service then iterates over
# and adds users to respective groups. See `SamlGroupSyncWorker` for an
# example.
#
module Groups
  class SyncService < Groups::BaseService
    include Gitlab::Utils::StrongMemoize

    def execute
      return unless group

      remove_old_memberships
      update_current_memberships

      ServiceResponse.success
    end

    private

    def remove_old_memberships
      members_to_destroy.each do |member|
        Members::DestroyService.new(current_user).execute(member, skip_authorization: true)
      end
    end

    def update_current_memberships
      group_links_by_group.each do |group_id, group_links|
        access_level = max_access_level(group_links)

        existing_member = existing_member_by_group(group_id)
        next if existing_member && existing_member.access_level == access_level

        Group.find_by_id(group_id)&.add_user(current_user, access_level)
      end
    end

    def members_to_destroy
      existing_members.select do |member|
        !group_links_by_group.key?(member.source_id) &&
          (manage_group_ids.blank? || manage_group_ids.include?(member.source_id))
      end
    end

    def existing_member_by_group(group_id)
      existing_members.find { |member| member.source_id == group_id }
    end

    def existing_members
      strong_memoize(:existing_members) do
        group.members_with_descendants.with_user(current_user).to_a
      end
    end

    def group_links_by_group
      strong_memoize(:group_links_by_group) do
        params[:group_links].group_by(&:group_id)
      end
    end

    def manage_group_ids
      params[:manage_group_ids]
    end

    def max_access_level(group_links)
      human_access_level = group_links.map(&:access_level)
      human_access_level.map { |level| integer_access_level(level) }.max
    end

    def integer_access_level(human_access_level)
      ::Gitlab::Access.options_with_owner[human_access_level]
    end
  end
end
