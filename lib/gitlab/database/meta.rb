# frozen_string_literal: true

module Gitlab
  module Database
    module Meta
      TableMeta = Struct.new(:owner, :description, :version) do
        VERSION = '1.0'

        def initialize(owner, description, version = VERSION)
          super(owner, description, version)
        end
      end

      module MigrationHelper
        def table_description(table, owner:, description: nil)
          meta = Meta::TableMeta.new(owner, description)

          Meta::TableMetaPersistence.new(table).write(meta)
        end

        def clear_table_description(table)
          Meta::TableMetaPersistence.new(table).clear
        end
      end

      class Comment < ActiveRecord::Base
        self.table_name = :postgres_table_comments
        self.primary_key = :identifier

        def readonly?
          true
        end
      end

      class TableMetaPersistence
        attr_reader :schema, :table_name

        def initialize(table_name, schema: connection.current_schema)
          @schema = schema
          @table_name = table_name
        end

        def identifier
          "#{schema}.#{table_name}"
        end

        def write(meta)
          set_comment(meta.to_json)
        end

        def clear
          set_comment(nil)
        end

        def read
          payload = Gitlab::Json.parse(Comment.find(identifier).comment)

          TableMeta.new(payload['owner'], payload['description'], payload['version'])
        rescue ActiveRecord::NotFound
          nil
        end

        private

        def set_comment(comment)
          connection = Comment.connection
          connection.execute("COMMENT ON TABLE #{connection.quote_table_name(schema)}.#{connection.quote_table_name(table_name)} IS #{connection.quote(comment)}")
        end

        def connection
          ActiveRecord::Base.connection
        end
      end
    end
  end
end
