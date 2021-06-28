# frozen_string_literal: true

module Gitlab
  module Database
    module PostgresqlDatabaseTasks
      module LoadSchemaVersionsMixin
        extend ActiveSupport::Concern

        def structure_load(...)
          result = super(...)

          if ActiveRecord::Base.configurations.primary?(connection.pool.db_config.name)
            Gitlab::Database::SchemaVersionFiles.load_all(connection.pool.db_config.name)
          else
            result
          end
        end
      end
    end
  end
end
