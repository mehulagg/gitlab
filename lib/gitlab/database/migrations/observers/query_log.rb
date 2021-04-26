# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      module Observers
        class QueryLog < MigrationObserver
          def before
            @logger_was = ActiveRecord::Base.logger
            @log = File.open(File.join(Instrumentation::RESULT_DIR, 'current.log'), 'wb+')
            ActiveRecord::Base.logger = Logger.new(@log)
          end

          def after
            ActiveRecord::Base.logger = @logger_was
            @log.close
          end

          def record(observation)
            File.rename(@log.path, File.join(Instrumentation::RESULT_DIR, "#{observation.migration}.log"))
          end
        end
      end
    end
  end
end
