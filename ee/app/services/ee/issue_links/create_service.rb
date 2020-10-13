# frozen_string_literal: true

module EE
  module IssueLinks
    module CreateService
      def execute
        if params[:link_type].present?
          return error('Blocked issues not available for current license', 403) unless link_type_available?
        end

        super
      end

      private

      def set_link_type(link)
        if params[:link_type].present?
          link.link_type = params[:link_type]
        end
      end

      def link_type_available?
        return true unless [::IssueLink::TYPE_BLOCKS, ::IssueLink::TYPE_IS_BLOCKED_BY].include?(params[:link_type])

        issuable.resource_parent.feature_available?(:blocked_issues)
      end
    end
  end
end
