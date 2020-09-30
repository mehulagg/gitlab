# frozen_string_literal: true

module EE
  module Boards
    module ListsController
      extend ::Gitlab::Utils::Override

      included do
        before_action :push_licensed_features
      end

      EE_MAX_LIMITS_PARAMS = %i[max_issue_count max_issue_weight limit_metric].freeze

      override :list_creation_attrs
      def list_creation_attrs
        additional_attrs = %i[assignee_id milestone_id]
        additional_attrs += EE_MAX_LIMITS_PARAMS if wip_limits_available?

        super + additional_attrs
      end

      override :list_update_attrs
      def list_update_attrs
        return super unless wip_limits_available?

        super + EE_MAX_LIMITS_PARAMS
      end

      override :serialization_attrs
      def serialization_attrs
        super.merge(user: true, milestone: true).tap do |attrs|
          attrs[:only] += EE_MAX_LIMITS_PARAMS if wip_limits_available?
        end
      end

      private

      def wip_limits_available?
        board_parent.feature_available?(:wip_limits)
      end
    end
  end
end
