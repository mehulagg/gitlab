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
      push_frontend_feature_flag(:wip_limits, type: :licensed, default_enabled: true) if parent.feature_available?(:wip_limits)
      push_frontend_feature_flag(:swimlanes, type: :licensed, default_enabled: true) if parent.feature_available?(:swimlanes)
    end
  end
end
