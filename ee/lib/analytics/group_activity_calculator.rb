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
      # Clear db load balancing session so that primary sticking
      # does not apply in case a write has happened recently.
      # We want to make sure the load of the following query
      # does not land on the primary db.
      ::Gitlab::Database::LoadBalancing::Session.clear_session

      @merge_requests_count ||=
        Groups::RecentMergeRequestsCountService.new(@group, @current_user, params).count
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
  end
end
