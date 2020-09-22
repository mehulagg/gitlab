# frozen_string_literal: true

module EE
  module Gitlab
    module SearchResults
      extend ::Gitlab::Utils::Override

      override :formatted_count
      def formatted_count(scope)
        count = super

        return count if count

        case scope
        when 'epics'
          formatted_limited_count(limited_epics_count)
        end
      end

      def epics
        groups_finder = GroupsFinder.new(current_user)

        ::Epic.in_selected_groups(groups_finder.execute).search(query)
      end

      private

      override :projects
      def projects
        super.with_compliance_framework_settings
      end

      override :collection_for
      def collection_for(scope)
        collection = super

        return collection if collection

        case scope
        when 'epics'
          epics
        end
      end

      def limited_epics_count
        @limited_epics_count ||= limited_count(epics)
      end
    end
  end
end
