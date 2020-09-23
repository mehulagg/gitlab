# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module Summary
        module Group
          class StageTimeSummary
            attr_reader :group, :current_user, :options

            def initialize(group, options:)
              @group = group
              @current_user = options[:current_user]
              @options = options
            end

            def data
              [lead_time]
            end

            private

            def lead_time
              serialize(
                Summary::Group::LeadTime.new(
                  group: group, current_user: current_user, options: options
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
end
