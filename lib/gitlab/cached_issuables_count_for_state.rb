# frozen_string_literal: true

module Gitlab
  # Class for counting and caching the number of issuables per state using the Redis Store.
  class CachedIssuablesCountForState < Gitlab::IssuablesCountForState
    include Gitlab::Utils::StrongMemoize
    CACHE_EXPIRES_IN = 1.hour

    attr_reader :finder, :parent

    # finder - The finder class to use for retrieving the issuables.
    # parent - The parent object, can be a Group or a Project.
    # fast_fail - restrict counting to a shorter period, degrading gracefully on
    # failure
    def initialize(finder, parent, fast_fail: false)
      super(finder, fast_fail)
      @parent = parent
    end

    private

    def cache_for_finder
      return super if parent.nil? || params_include_filters?

      Rails.cache.fetch(redis_cache_key, cache_options) { perform_count(finder) }
    end

    def redis_cache_key
      key = [parent_type, parent.id, finder.class.name]
      return key if skip_confidentiality_check?

      visibility = user_is_at_least_reporter? ? 'total' : 'public'
      key.push(visibility)
    end

    def cache_options
      { expires_in: CACHE_EXPIRES_IN }
    end

    def user_is_at_least_reporter?
      group = parent_type == 'project' ? parent.group : parent

      strong_memoize(:user_is_at_least_reporter) do
        finder.current_user && group.member?(finder.current_user, Gitlab::Access::REPORTER)
      end
    end

    def skip_confidentiality_check?
      return true if finder.instance_of?(MergeRequestsFinder)

      false
    end

    def parent_type
      if parent.is_a?(Group)
        'group'
      elsif parent.is_a?(Project)
        'project'
      end
    end

    def params_include_filters?
      filters = finder.class.valid_params.collect { |item| item.is_a?(Hash) ? item.keys : item }.flatten
      finder.params.slice(*filters).any?
    end
  end
end
