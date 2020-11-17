# frozen_string_literal: true

#
# Usage example:
#
# Groups::SyncService.new(nil, user, group_links: array_of_group_links).execute
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
    def execute
      group_links_by_group.each do |group_id, group_links|
        access_level = max_access_level(group_links)
        Group.find_by_id(group_id)&.add_user(current_user, access_level)
      end
    end

    private

    def group_links_by_group
      params[:group_links].group_by(&:group_id)
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
