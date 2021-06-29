# frozen_string_literal: true

module EE
  module Gitlab
    module GroupSearchResults
      extend ::Gitlab::Utils::Override

      def epics
        epics = EpicsFinder.new(current_user, issuable_params).execute.search(query)

        apply_sort(epics)
      end
    end
  end
end
