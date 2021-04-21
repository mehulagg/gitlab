# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class DatabaseMetric < BaseMetric
          # Usage Example
          #
          # class CountUsersCreatingIssuesMetric < DatabaseMetric
          #   operation :distinct_count, column: :author_id
          #
          #   relation do |database_time_constraints|
          #     ::Issue.where(database_time_constraints)
          #   end
          # end
          class << self
            def start(column = nil, &block)
              @metric_start = if block_given?
                                yield
                              else
                                column
                              end
            end

            def finish(column = nil, &block)
              @metric_finish = if block_given?
                                 yield
                               else
                                 column
                               end
            end

            def relation(&block)
              @metric_relation = block
            end

            def operation(symbol, column: nil)
              @metric_operation = symbol
              @column = column
            end

            attr_reader :metric_operation, :metric_relation, :metric_start, :metric_finish, :column
          end

          def value
            method(self.class.metric_operation)
              .call(self.class.metric_relation.call(database_time_constraints),
                    self.class.column,
                    start: self.class.metric_start,
                    finish: self.class.metric_finish)
          end
        end
      end
    end
  end
end
