# frozen_string_literal: true

module Groups
  # Service class for counting and caching the number of open merge requests of a group.
  class MergeRequestsCountService < Groups::CountService
    def count(state = 'opened')
      cached_count = Rails.cache.read(cache_key(state))
      return cached_count unless cached_count.blank?

      finder = MergeRequestsFinder.
        new(user, group_id: group.id, non_archived: true, include_subgroups: true)

      issuables_counter = Gitlab::IssuablesCountForState.new(finder)

      # get every state returned by above group call but only set the ones that pass threshold
      Gitlab::IssuablesCountForState::STATES.each do |mr_state|
        mr_state_count = issuables_counter[mr_state]
        update_cache_for_key(cache_key(mr_state)) { mr_state_count } if mr_state_count > CACHED_COUNT_THRESHOLD
      end

      return issuables_counter[state]
    end

    def cache_key state
      ['groups', "merge_requests_count_service", VERSION, group.id, "#{state}_merge_requests_count"]
    end end
end
