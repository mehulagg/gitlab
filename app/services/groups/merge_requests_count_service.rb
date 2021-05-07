# frozen_string_literal: true

module Groups
  # Service class for counting and caching the number of merge requests (by state) for a group and its subgroups
  class MergeRequestsCountService < Groups::CountService
    def count state
      cached_count = Rails.cache.read(cache_key(state))
      return cached_count unless cached_count.blank?

      # update counter for merge request count for each state and cache it if above count threshold
      Gitlab::IssuablesCountForState::STATES.each do |mr_state|
        mr_state_count = issuables_counter[mr_state]
        update_cache_for_key(cache_key(mr_state)) { mr_state_count } if mr_state_count > CACHED_COUNT_THRESHOLD
      end

      issuables_counter[state]
    end

    def cache_key state
      ['groups', "merge_requests_count_service", VERSION, group.id, "#{state}_merge_requests_count"]
    end

    private

    # Use Gitlab::IssuablesCountForState as counter for number of MRs in each state for a specific group
    # and cache the instantiated object for the duration of the request
    def issuables_counter
      return Gitlab::SafeRequestStore[request_store_key] if Gitlab::SafeRequestStore[request_store_key]

      finder = MergeRequestsFinder.new(user, group_id: group.id, non_archived: true, include_subgroups: true)
      Gitlab::SafeRequestStore[request_store_key] = Gitlab::IssuablesCountForState.new(finder)
    end

    def request_store_key
      ['groups', "merge_requests_count_service", VERSION, group.id]
    end
  end
end
