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
        with_correct_connection(table_name) do
          super(underlying_table(table_name))
        end
      end

      def columns(table_name)
        with_correct_connection(table_name) do
          super(underlying_table(table_name))
        end
      end

      def columns_hash(table_name)
        with_correct_connection(table_name) do
          super(underlying_table(table_name))
        end
      end

      def indexes(table_name)
        with_correct_connection(table_name) do
          super(underlying_table(table_name))
        end
      end

      private

      def with_correct_connection(table_name)
        previous_connection = connection

        # TODO: CI Vertical
        # TODO: This is a little hacky and we'd prefer to use the model somehow to get the right connection but we may not have models available in this context
        self.connection = if table_name.to_s.start_with?("ci_") || table_name.to_s == "tags" || table_name.to_s == "taggings"
                            ::Ci::ApplicationRecord.connection
                          else
                            ActiveRecord::Base.connection
                          end

        # TODO: CI Vertical: debug if we can not use it
        # puts "#with_correct_connection: #{table_name}: current=#{self.connection.connection_klass}, previous=#{previous_connection.connection_klass}"

        result = yield

        self.connection = previous_connection

        result
      end

      def underlying_table(table_name)
        renamed_tables_cache.fetch(table_name, table_name)
      end

      def renamed_tables_cache
        @renamed_tables ||= begin
          Gitlab::Database::TABLES_TO_BE_RENAMED.select do |old_name, new_name|
            with_correct_connection(old_name) do
              connection.view_exists?(old_name)
            end
          end
        end
      end

      def clear_renamed_tables_cache!
        @renamed_tables = nil # rubocop:disable Gitlab/ModuleWithInstanceVariables
      end
    end
  end
end
