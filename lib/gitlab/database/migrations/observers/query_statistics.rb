# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      module Observers
        class QueryStatistics < MigrationObserver
          def before
            connection.execute('select pg_stat_statements_reset()')
          end

          def record(observation)
            observation.query_statistics = connection.execute('select query, calls, total_time, max_time, mean_time, rows from pg_stat_statements order by total_time desc')
          end
        end
      end
    end
  end
end
