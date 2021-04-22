# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class CountBoardsMetric < DatabaseMetric
          operation :count

          relation do |database_time_constraints|
            Board.where(database_time_constraints)
          end
        end
      end
    end
  end
end
