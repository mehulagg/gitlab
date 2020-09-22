# frozen_string_literal: true

module EE
  module Gitlab
    module GroupSearchResults
      extend ::Gitlab::Utils::Override

      override :epics
      def epics
        EpicsFinder.new(current_user, issuable_params).execute.search(query)
      end
    end
  end
end
