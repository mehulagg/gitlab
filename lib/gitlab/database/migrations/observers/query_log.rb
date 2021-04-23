# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      module Observers
        class QueryLog < MigrationObserver
          def initialize
            super

            @log = StringIO.new
            @logger_was = ActiveRecord::Base.logger
          end

          def before
            ActiveRecord::Base.logger = Logger.new(@log)
          end

          def after
            ActiveRecord::Base.logger = @logger_was
          end

          def record(observation)
            observation.query_log = @log.string
          end
        end
      end
    end
  end
end
