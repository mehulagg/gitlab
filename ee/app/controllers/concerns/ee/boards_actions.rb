# frozen_string_literal: true

module EE
  module BoardsActions
    extend ActiveSupport::Concern

    prepended do
      include ::MultipleBoardsActions
    end

    private

    def push_licensed_features
      # This is pushing a licensed Feature to the frontend.
      #
      # push_frontend_feature_flag(:wip_limits, type: :licensed, default_enabled: true) if parent.feature_available?(:wip_limits)
      # ::Gitlab::Abilities::WipLimit.push_frontend(parent: parent)
      push_frontend_ability(::Gitlab::Abilities::WipLimit, parent: parent)
      # push_frontend_feature_flag(:swimlanes, type: :licensed, default_enabled: true) if parent.feature_available?(:swimlanes)
      push_frontend_feature_flag(:issue_weights, type: :licensed, default_enabled: true) if parent.feature_available?(:issue_weights)
    end
  end
end
