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
            ActiveRecord::Base.logger = Logger.new(@log)
          end

          def record(observation)
            observation.query_log = @log.string
          end
        end
      end
    end
  end
end
