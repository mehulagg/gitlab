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
      push_frontend_feature_available(:wip_limits, parent)

      # it seems to be a valid feature flag
      push_frontend_feature_available(:swimlanes, parent)
    end
  end
end
