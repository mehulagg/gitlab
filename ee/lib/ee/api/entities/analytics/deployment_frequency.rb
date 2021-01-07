# frozen_string_literal: true

module EE
  module API
    module Entities
      module Analytics
        class DeploymentFrequency < Grape::Entity
          expose :value
          expose :from
          expose :to
        end
      end
    end
  end
end
