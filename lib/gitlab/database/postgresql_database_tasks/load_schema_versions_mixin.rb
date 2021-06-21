# frozen_string_literal: true

module Gitlab
  module Database
    module PostgresqlDatabaseTasks
      module LoadSchemaVersionsMixin
        extend ActiveSupport::Concern

        def structure_load(...)
          result = super(...)

          if connection.pool.db_config.name == 'primary'
            Gitlab::Database::SchemaVersionFiles.load_all
          else
            result
          end
        end
      end
    end
  end
end
