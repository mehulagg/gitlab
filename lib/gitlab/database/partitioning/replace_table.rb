# frozen_string_literal: true

module Gitlab
  module Database
    module Partitioning
      class ReplaceTable
        def initialize(original_table, replacement_table, replaced_table, primary_key_column)
          @original_table = quote_table_name(original_table)
          @replacement_table = quote_table_name(replacement_table)
          @replaced_table = quote_table_name(replaced_table)
          @primary_key_column = quote_table_name(primary_key_column)

          @sequence = quote_table_name("#{original_table}_#{primary_key_column}_seq")
          @original_primary_key = quote_column_name("#{original_table}_pkey")
          @replacement_primary_key = quote_column_name("#{replacement_table}_pkey")
          @replaced_primary_key = quote_column_name("#{replaced_table}_pkey")
        end

        def perform
          yield sql_to_replace_table if block_given?

          execute(sql_to_replace_table)
        end

        private

        attr_reader :original_table, :replacement_table, :replaced_table, :primary_key_column,
          :sequence, :original_primary_key, :replacement_primary_key, :replaced_primary_key

        delegate :execute, :quote_table_name, :quote_column_name, to: :connection
        def connection
          @connection ||= ActiveRecord::Base.connection
        end

        def sql_to_replace_table
          @sql_to_replace_table ||= <<~SQL
            ALTER TABLE #{original_table}
            ALTER COLUMN #{primary_key_column} DROP DEFAULT;

            ALTER TABLE #{replacement_table}
            ALTER COLUMN #{primary_key_column} SET DEFAULT nextval('#{sequence}'::regclass);

            ALTER SEQUENCE #{sequence}
            OWNED BY #{replacement_table}.#{primary_key_column};

            ALTER TABLE #{original_table} RENAME TO #{replaced_table};

            ALTER TABLE #{replaced_table}
            RENAME CONSTRAINT #{original_primary_key} TO #{replaced_primary_key};

            ALTER TABLE #{replacement_table} RENAME TO #{original_table};

            ALTER TABLE #{original_table}
            RENAME CONSTRAINT #{replacement_primary_key} TO #{original_primary_key};
          SQL
        end
      end
    end
  end
end
