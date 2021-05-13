# frozen_string_literal: true

module Analytics
  class GroupActivityCalculator
    DURATION = 90.days

    def initialize(group, current_user)
      @group = group
      @current_user = current_user
    end

    def issues_count
      @issues_count ||=
        IssuesFinder.new(@current_user, params).execute.count
    end

    def merge_requests_count
      @merge_requests_count ||=
        # We want to make sure the load of the following query
        # lands on the read replica instead of the primary db
        current_load_balancing_session.use_replicas_for_read_queries do
          count_service.new(@group, @current_user, params).count
        end
    end

    def new_members_count
      @new_members_count ||=
        GroupMembersFinder.new(
          @group,
          @current_user,
          params: { created_after: DURATION.ago }
        ).execute(include_relations: [:direct, :descendants]).count
    end

    private

    def params
      { group_id: @group.id,
        state: 'all',
        created_after: DURATION.ago,
        include_subgroups: true,
        attempt_group_search_optimizations: true,
        attempt_project_search_optimizations: true }
    end

    def current_load_balancing_session
      ::Gitlab::Database::LoadBalancing::Session.current
    end

    def count_service
      Groups::RecentMergeRequestsCountService
    end
  end
end
