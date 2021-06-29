# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module Summary
        class StageTimeSummary
          attr_reader :stage, :current_user, :options

          def initialize(stage, options:)
            @stage = stage
            @current_user = options[:current_user]
            @options = options
          end

          def data
            [lead_time, cycle_time]
          end

          private

          def lead_time
            serialize(
              Summary::LeadTime.new(
                stage: stage, current_user: current_user, options: options
              ),
              with_unit: true
            )
          end

          def cycle_time
            serialize(
              Summary::CycleTime.new(
                stage: stage, current_user: current_user, options: options
              ),
              with_unit: true
            )
          end

          def serialize(summary_object, with_unit: false)
            AnalyticsSummarySerializer.new.represent(
              summary_object, with_unit: with_unit)
          end
        end
      end
    end
  end
end
