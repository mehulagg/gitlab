# frozen_string_literal: true

module Gitlab
  module Database
    module RenameTablePatch
      # Override methods in ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
      module PostgreSQLAdapter
        def primary_keys(table_name)
          super(schema_cache.underlying_table(table_name))
        end

        def indexes(table_name)
          super(schema_cache.underlying_table(table_name))
        end

        def foreign_keys(table_name)
          super(schema_cache.underlying_table(table_name))
        end

        def columns(table_name)
          super(schema_cache.underlying_table(table_name))
        end
      end

      # Override methods in ActiveRecord::ConnectionAdapters::SchemaCache
      module SchemaCache
        def clear!
          super

          clear_renamed_tables_cache!
        end

        def clear_data_source_cache!(name)
          super(name)

          clear_renamed_tables_cache!
        end

        def primary_keys(table_name)
          super(underlying_table(table_name))
        end

        def columns(table_name)
          super(underlying_table(table_name))
        end

        def columns_hash(table_name)
          super(underlying_table(table_name))
        end

        def indexes(table_name)
          super(underlying_table(table_name))
        end

        def underlying_table(table_name)
          renamed_tables_cache.fetch(table_name, table_name)
        end

        private

        def renamed_tables_cache
          @renamed_tables ||= begin
            Gitlab::Database::TABLES_TO_BE_RENAMED.select do |old_name, new_name|
              ActiveRecord::Base.connection.view_exists?(old_name)
            end
          end
        end

        def clear_renamed_tables_cache!
          @renamed_tables = nil # rubocop:disable Gitlab/ModuleWithInstanceVariables
        end
      end
    end
  end
end
