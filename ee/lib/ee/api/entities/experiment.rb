# frozen_string_literal: true

module EE
  module API
    module Entities
      class Experiment < ::API::Entities::Feature::Definition
        expose :key
        expose :enabled
        expose :state
      end
    end
  end
end
