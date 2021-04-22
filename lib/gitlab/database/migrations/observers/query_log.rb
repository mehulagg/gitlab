# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      module Observers
        class QueryLog < MigrationObserver
          def initialize
            super

            @logs = []
          end

          def before
            ActiveSupport::Notifications.subscribe("sql.active_record") do |_, start, finish, _, data|
              @logs << {
                query: data[:sql],
                duration: (finish - start) * 1000.0
              }
            end
          end

          def record(observation)
            observation.query_log = @logs
          end
        end
      end
    end
  end
end
