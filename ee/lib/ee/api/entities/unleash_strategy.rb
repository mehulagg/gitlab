# frozen_string_literal: true

module EE
  module API
    module Entities
      class UnleashStrategy < Grape::Entity
        expose :name
        expose :parameters
      end
    end
  end
end
