# frozen_string_literal: true

module Gitlab
  module Database
    module SchemaCacheWithRenamedTable
      # Override methods in ActiveRecord::ConnectionAdapters::SchemaCache

      def clear!
        super

        clear_renamed_tables_cache!
      end

      def clear_data_source_cache!(name)
        super(name)

        clear_renamed_tables_cache!
      end

      def primary_keys(table_name)
        super(with_renamed_table(table_name))
      end

      def columns(table_name)
        super(with_renamed_table(table_name))
      end

      def columns_hash(table_name)
        super(with_renamed_table(table_name))
      end

      def indexes(table_name)
        super(with_renamed_table(table_name))
      end

      private

      def with_renamed_table(table_name)
        renamed_tables_cache[table_name] || table_name
      end

      def renamed_tables_cache
        @renamed_tables ||= begin
          rename_table_definitions = ActiveRecord::Base.descendants.map { |model| model.table_rename_metadata if model.respond_to?(:table_rename_metadata) }.compact
          rename_table_definitions.select! { |from, to| ActiveRecord::Base.connection.table_exists?(to) }

          Hash[rename_table_definitions]
        end
      end

      def clear_renamed_tables_cache!
        @renamed_tables = nil # rubocop:disable Gitlab/ModuleWithInstanceVariables
      end
    end
  end
end
