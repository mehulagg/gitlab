# frozen_string_literal: true

module Gitlab
  module Search
    class RecentEpics < RecentItems
      extend ::Gitlab::Utils::Override

      override :search
      # rubocop: disable CodeReuse/ActiveRecord
      def search(term)
        epics = Epic.full_search(term, matched_columns: 'title')
          .id_in_ordered(latest_ids).limit(::Gitlab::Search::RecentItems::SEARCH_LIMIT)

        # Since EpicsFinder does not support searching globally (ie. applying
        # global permissions) the most efficient option is just to load the
        # last 5 matching recently viewed epics and then do an explicit
        # permissions check
        disallowed = epics.reject { |epic| Ability.allowed?(user, :read_epic, epic) }

        return epics if disallowed.empty?

        epics.where.not(id: disallowed.map(&:id))
      end
      # rubocop: enable CodeReuse/ActiveRecord

      private

      def type
        Epic
      end
    end
  end
end
