# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      class DataForDurationChart
        include StageQueryHelpers

        MAX_RESULTS = 500

        def initialize(stage:, params:, query:)
          @stage = stage
          @params = params
          @query = query
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def average_by_day
          date = Arel::Nodes::NamedFunction.new('DATE', [stage.end_event.timestamp_projection])
          average = round_duration_to_seconds.average

          @query
            .reorder(nil)
            .group(date)
            .select(date.dup.as('date'), average.as('average_duration_in_seconds'))
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        attr_reader :stage, :query, :params
      end
    end
  end
end
