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
      push_licensed_feature(:wip_limits, parent)
      push_licensed_feature(:swimlanes, parent)
      push_licensed_feature(:issue_weights, parent)
    end
  end
end
