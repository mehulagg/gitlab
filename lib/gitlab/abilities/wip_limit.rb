# frozen_string_literal: true

module Gitlab
  module Abilities
    class WipLimit
      class << self
        def enabled?(parent: nil)
          parent.feature_available?(:swimlanes)
        end

        def name
          :swimlanes
        end
      end
    end
  end
end
