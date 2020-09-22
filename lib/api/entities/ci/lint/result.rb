# frozen_string_literal: true

module API
  module Entities
    module Ci
      module Lint
        class Result < Grape::Entity
          expose :valid?, as: :valid
          expose :errors
          expose :warnings
        end
      end
    end
  end
end
