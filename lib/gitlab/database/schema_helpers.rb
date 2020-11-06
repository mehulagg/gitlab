# frozen_string_literal: true

module Gitlab
  module Database
    module SchemaHelpers
      def create_trigger_function(name, replace: true)
        replace_clause = optional_clause(replace, "OR REPLACE")
        connection.execute(<<~SQL)
          CREATE #{replace_clause} FUNCTION #{name}()
          RETURNS TRIGGER AS
          $$
          BEGIN
          #{yield}
          END
          $$ LANGUAGE PLPGSQL
        SQL
      end

      def function_exists?(name)
        connection.select_value(<<~SQL)
          SELECT 1
          FROM pg_catalog.pg_proc
          WHERE proname = #{connection.quote(name)}
        SQL
      end

      def create_trigger(table_name, name, function_name, fires:)
        connection.execute(<<~SQL)
          CREATE TRIGGER #{name}
          #{fires} ON #{connection.quote_table_name(table_name)}
          FOR EACH ROW
          EXECUTE FUNCTION #{function_name}()
        SQL
      end

      def trigger_exists?(table_name, name)
        connection.select_value(<<~SQL)
          SELECT 1
          FROM pg_catalog.pg_trigger trgr
            INNER JOIN pg_catalog.pg_class rel
              ON trgr.tgrelid = rel.oid
            INNER JOIN pg_catalog.pg_namespace nsp
              ON nsp.oid = rel.relnamespace
          WHERE nsp.nspname = #{connection.quote(connection.current_schema)}
            AND rel.relname = #{connection.quote(table_name)}
            AND trgr.tgname = #{connection.quote(name)}
        SQL
      end

      def drop_function(name, if_exists: true)
        exists_clause = optional_clause(if_exists, "IF EXISTS")
        connection.execute("DROP FUNCTION #{exists_clause} #{name}()")
      end

      def drop_trigger(table_name, name, if_exists: true)
        exists_clause = optional_clause(if_exists, "IF EXISTS")
        connection.execute("DROP TRIGGER #{exists_clause} #{name} ON #{connection.quote_table_name(table_name)}")
      end

      def create_comment(type, name, text)
        connection.execute("COMMENT ON #{type} #{connection.quote_table_name(name)} IS '#{text}'")
      end

      def tmp_table_name(base)
        hashed_base = Digest::SHA256.hexdigest(base).first(10)

        "#{base}_#{hashed_base}"
      end

      def object_name(table, type)
        identifier = "#{table}_#{type}"
        hashed_identifier = Digest::SHA256.hexdigest(identifier).first(10)

        "#{type}_#{hashed_identifier}"
      end

      def with_lock_retries(&block)
        Gitlab::Database::WithLockRetries.new(
          klass: self.class,
          logger: Gitlab::BackgroundMigration::Logger
        ).run(&block)
      end

      def assert_not_in_transaction_block(scope:)
        return unless connection.transaction_open?

        raise "#{scope} operations can not be run inside a transaction block, " \
          "you can disable transaction blocks by calling disable_ddl_transaction! " \
          "in the body of your migration class"
      end

      private

      def table_for_range_partition(partition_name)
        "#{Gitlab::Database::DYNAMIC_PARTITIONS_SCHEMA}.#{partition_name}"
      end

      def create_range_partition(partition_name, table_name, lower_bound, upper_bound)
        partition_identifier = table_for_range_partition(partition_name)

        connection.execute(<<~SQL)
          CREATE TABLE #{connection.quote_table_name(partition_identifier)}
          PARTITION OF #{connection.quote_table_name(table_name)}
          FOR VALUES FROM (#{lower_bound}) TO (#{upper_bound})
        SQL
      end

      def optional_clause(flag, clause)
        flag ? clause : ""
      end
    end
  end
end
