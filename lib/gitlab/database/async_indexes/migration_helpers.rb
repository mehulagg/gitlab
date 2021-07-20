# frozen_string_literal: true

module Gitlab
  module Database
    module AsyncIndexes
      module MigrationHelpers
        def unprepare_async_index(table_name, column_name, **options)
          raise 'Specifying index name is mandatory - specify name: argument' unless options[:name]

          unprepare_async_index_by_name(table_name, options[:name])
        end

        def unprepare_async_index_by_name(table_name, index_name, **options)
          PostgresAsyncIndex.find_by(name: index_name).try do |async_index|
            async_index.destroy
          end
        end

        def prepare_async_index(table_name, column_name, **options)
          raise 'Specifying index name is mandatory - specify name: argument' unless options[:name]

          return unless Feature.enabled?(:database_async_index_creation, type: :ops)

          options = options.merge({ algorithm: :concurrently })

          if index_exists?(table_name, column_name, **options)
            Gitlab::AppLogger.warn "Index not created because it already exists: table_name: #{table_name}, column_name: #{column_name}"
            return
          end

          index, algorithm, if_not_exists = add_index_options(table_name, column_name, **options)

          create_index = ActiveRecord::ConnectionAdapters::CreateIndexDefinition.new(index, algorithm, if_not_exists)
          schema_creation = ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaCreation.new(ApplicationRecord.connection)
          definition = schema_creation.accept(create_index)

          async_index = PostgresAsyncIndex.find_or_create_by(name: options[:name]) do |rec|
            rec.table_name = table_name
            rec.definition = definition
          end

          Gitlab::AppLogger.info "Prepared for async index creation: #{async_index}"

          async_index
        end
      end
    end
  end
end
