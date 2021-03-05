# frozen_string_literal: true

module Groups
  class CountService < BaseCountService
    include Gitlab::Utils::StrongMemoize

    VERSION = 1
    CACHED_COUNT_THRESHOLD = 1000
    EXPIRATION_TIME = 24.hours

    attr_reader :group, :user

    def initialize(group, user = nil)
      @group = group
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

    def cache_key
      ['groups', "#{issuable_key}_count_service", VERSION, group.id, cache_key_name]
    end

    private

    def cache_options
      super.merge({ expires_in: EXPIRATION_TIME })
    end

    def cache_key_name
      raise NotImplementedError
    end

    def relation_for_count
      raise NotImplementedError
    end

    def issuable_key
      ''
    end
  end
end
