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
            ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, data|
              @logs << data[:sql]
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
