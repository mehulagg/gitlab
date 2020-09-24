# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    module Stages
      class CreateService < BaseService
        def initialize(parent:, current_user:, params:)
          super

          @stage = parent.cycle_analytics_stages.build(params)
        end

        def execute
          return forbidden unless can?(current_user, :create_group_stage, parent)
          return error(stage) unless stage.valid?

          parent.class.transaction do
            persist_default_stages!
            stage.value_stream ||= value_stream
            stage.save!
          end

          success(stage)
        end

        private

        attr_reader :stage
      end
    end
  end
end
