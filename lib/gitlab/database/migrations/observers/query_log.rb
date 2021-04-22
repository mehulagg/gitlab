# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      module Observers
        class QueryLog < MigrationObserver
          def initialize
            super

            @log = StringIO.new
          end

          def before
            ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, data|
              @log << data[:sql]
              @log << "\n"
            end
          end

          def record(observation)
            observation.query_log = @log.string
          end
        end
      end
    end
  end
end
