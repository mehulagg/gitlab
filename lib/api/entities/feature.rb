# frozen_string_literal: true

module API
  module Entities
    class Feature < Grape::Entity
      expose :name
      expose :state
      expose :gates, using: Entities::FeatureGate do |model|
        model.gates.map do |gate|
          value = model.gate_values[gate.key]

          # By default all gate values are populated. Only show relevant ones.
          if (value.is_a?(Integer) && value == 0) || (value.is_a?(Set) && value.empty?)
            next
          end

          { key: gate.key, value: value }
        end.compact
      end

      expose :has_definition do |feature|
        ::Feature::Definition.has_definition?(feature.name)
      end
    end
  end
end
