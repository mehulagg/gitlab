# frozen_string_literal: true

module EE
  module Gitlab
    module SearchResults
      extend ::Gitlab::Utils::Override

      override :formatted_count
      def formatted_count(scope)
        case scope
        when 'epics'
          formatted_limited_count(limited_epics_count)
        else
          super
        end
      end

      private

      override :projects
      def projects
        super.with_compliance_framework_settings
      end

      override :collection_for
      def collection_for(scope)
        case scope
        when 'epics'
          epics
        else
          super
        end
      end

      def limited_epics_count
        @limited_epics_count ||= limited_count(epics)
      end
    end
  end
end
