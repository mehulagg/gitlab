# frozen_string_literal: true

module Gitlab
  module Database
    module RenamedTable
      def clear!
        super

        clear_renamed_tables
      end

      def clear_data_source_cache!(name)
        super(name)

        clear_renamed_tables
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

      def with_renamed_table(table_name)
        renamed_tables_cache[table_name] || table_name
      end

      def renamed_tables_cache
        @renamed_tables ||= if ActiveRecord::Base.connection.table_exists?(:renamed_tables)
                              ActiveRecord::Base
                                .connection
                                .execute("SELECT old_name, new_name FROM renamed_tables")
                                .each_with_object({}) { |row, hash| hash[row['old_name']] = row['new_name'] }
                            else
                              {}
                            end
      end

      def clear_renamed_tables
        @renamed_tables = nil # rubocop:disable Gitlab/ModuleWithInstanceVariables
      end
    end
  end
end
