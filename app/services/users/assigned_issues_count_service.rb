# frozen_string_literal: true

module Users
  # Service class for counting and caching the number of assigned issues for a user.
  class AssignedIssuesCountService < BaseCountService
    include Gitlab::Utils::StrongMemoize

    VERSION = 1
    COUNT_KEY = 'user_open_assigned_issues_count'
    CACHED_COUNT_THRESHOLD = 1000
    EXPIRATION_TIME = 20.minutes

    attr_reader :user

    def initialize(user)
      @user = user
    end

    # Reads count value from cache and return it if present.
    # If empty or expired, #uncached_count will calculate the issues count for the group and
    # compare it with the threshold. If it is greater, it will be written to the cache and returned.
    # If below, it will be returned without being cached.
    # This results in only caching large counts and calculating the rest with every call to maintain
    # accuracy.
    def count
      cached_count = Rails.cache.read(cache_key)
      return cached_count unless cached_count.blank?

      refreshed_count = uncached_count
      update_cache_for_key(cache_key) { refreshed_count } if refreshed_count > CACHED_COUNT_THRESHOLD
      refreshed_count
    end

    def cache_key(key = nil)
      ['users', user.id, 'assigned_issues_count_service', VERSION, cache_key_name]
    end

    private

    def cache_options
      super.merge({ expires_in: EXPIRATION_TIME })
    end

    def cache_key_name
      COUNT_KEY
    end

    def relation_for_count
      IssuesFinder.new(user, assignee_id: user.id, state: 'opened', non_archived: true).execute
    end
  end
end
