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
        return unless params[:link_type].present?

        link.link_type = params[:link_type]

        # `blocked_by` links are treated as `blocks` links where
        # source and target is swapped. This is the first step toward
        # removing `blocked_by` link type
        # https://gitlab.com/gitlab-org/gitlab/-/issues/225919
        if link.is_blocked_by?
          link.source, link.target = link.target, link.source
          link.link_type = ::IssueLink::TYPE_BLOCKS
        end
      end

      def link_type_available?
        return true unless [::IssueLink::TYPE_BLOCKS, ::IssueLink::TYPE_IS_BLOCKED_BY].include?(params[:link_type])

        issuable.resource_parent.feature_available?(:blocked_issues)
      end
    end
  end
end
