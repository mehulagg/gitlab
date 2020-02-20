# frozen_string_literal: true

module Analytics
  class GroupActivityCalculator
    DURATION = 90.days.ago

    def initialize(group, current_user)
      @group = group
      @current_user = current_user
    end

    def issues_count
      @issues_count ||=
        IssuesFinder.new(
          @current_user,
          group_path: @group.id,
          state: 'all',
          non_archived: true,
          include_subgroups: true,
          created_at: "> #{DURATION}"
        ).execute
          .count
    end

    def merge_requests_count
      @merge_requests_count ||=
        MergeRequestsFinder.new(
          @current_user,
          group_path: @group.id,
          state: 'all',
          non_archived: true,
          include_subgroups: true,
          created_at: "> #{DURATION}"
        ).execute
          .count
    end
  end
end
