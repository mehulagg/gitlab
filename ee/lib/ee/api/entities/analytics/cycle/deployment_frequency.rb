# frozen_string_literal: true

module EE
  module API
    module Entities
      module Analytics
        module Cycle
          class DeploymentFrequency < Grape::Entity
            expose :value
            expose :unit
          end
        end
      end
    end
  end
end
