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
      push_frontend_beta_feature_available(:wip_limits, parent, default_enabled: true)
      push_frontend_beta_feature_available(:swimlanes, parent, default_enabled: true)
    end
  end
end
