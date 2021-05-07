# frozen_string_literal: true

module EE
  module API
    module Entities
      class Experiment < ::API::Entities::Feature::Definition
        expose :key do |definition|
          definition.attributes[:name].gsub(/_experiment_percentage$/, '')
        end

        expose :enabled do |definition|
          feature(definition).state != :off
        end

        expose :state do |definition|
          feature(definition).state
        end

        private

        def feature(definition)
          @feature ||= ::Feature.get(definition.attributes[:name]) # rubocop:disable Gitlab/AvoidFeatureGet
        end
      end
    end
  end
end
