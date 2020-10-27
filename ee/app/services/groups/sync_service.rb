# frozen_string_literal: true

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
      group_links.map(&:access_level).map { |level| ::Gitlab::Access.options_with_owner[level] }.max
    end
  end
end
