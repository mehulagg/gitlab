# frozen_string_literal: true

# Service class for counting and caching the number of open merge requests of
# a project.
module Groups
  class RecentMergeRequestsCountService < BaseCountService
    VERSION = 1
    DURATION = 90.days
    EXPIRES_IN = 24.hours

    def initialize(group, current_user, params)
      @group = group
      @current_user = current_user
      @params = params
    end

    private

    def relation_for_count
      MergeRequestsFinder.new(@current_user, @params).execute
    end

    def cache_key(key = nil)
      ['groups', 'recent_merge_requests_count_service', VERSION, @group.id, @current_user.id, cache_key_name]
    end

    def cache_key_name
      'recent_merge_requests_count'
    end

    def cache_options
      super.merge(expires_in: EXPIRES_IN)
    end
  end
end
