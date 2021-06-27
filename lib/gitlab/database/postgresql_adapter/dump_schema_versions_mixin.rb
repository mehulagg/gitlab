# frozen_string_literal: true

module Gitlab
  module Database
    module PostgresqlAdapter
      module DumpSchemaVersionsMixin
        extend ActiveSupport::Concern

        def dump_schema_information # :nodoc:
          versions = schema_migration.all_versions
          file_versions = migration_context.migrations.map { |m| m.version.to_s }
          Gitlab::Database::SchemaVersionFiles.touch_all(pool.db_config.name, versions, file_versions) if versions.any?

          nil
        end
      end
    end
  end
end
