# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      class Average
        include StageQueryHelpers

        def initialize(stage:, query:)
          @stage = stage
          @query = query
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def seconds
          @query = @query.select(average_in_seconds.as('average')).reorder(nil)
          result = execute_query(@query).first || {}

          result['average'] || nil
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def days
          seconds ? seconds.fdiv(1.day) : nil
        end

        private

        attr_reader :stage

        def average
          Arel::Nodes::NamedFunction.new(
            'AVG',
            [duration]
          )
        end

        def average_in_seconds
          Arel::Nodes::Extract.new(average, :epoch)
        end
      end
    end
  end
end
