# frozen_string_literal: true

connection = ApplicationRecord.connection
invalid_foreign_keys = nil

invalid_foreign_keys = [:gitlab_ci, :public, :gitlab_shared].flat_map do |schema_name|
  connection.transaction(requires_new: true) do
    connection.schema_search_path = schema_name
    all_tables = connection.tables.sort
    connection.schema_search_path = :undefined

    all_tables.flat_map do |table_name|
      connection.foreign_keys("#{schema_name}.#{table_name}")
        .reject { |fk| fk.to_table.start_with?("#{schema_name}.") }
    end
  end
end

def quote(name)
  return "null" if name.nil?
  return "\"set null\"" if name == :nullify

  "\"#{name}\""
end

def emit_up(fks)
  fks.map do |fk|
    from_table = fk.from_table.split('.').last
    to_table = fk.to_table.split('.').last

    "remove_foreign_key_if_exists(:#{from_table}, :#{to_table}, name: #{quote(fk.name)})"
  end
end

def emit_down(fks)
  fks.map do |fk|
    from_table = fk.from_table.split('.').last
    to_table = fk.to_table.split('.').last

    "add_concurrent_foreign_key(:#{from_table}, :#{to_table}, name: #{quote(fk.name)}, column: :#{fk.column}, target_column: :#{fk.primary_key}, on_delete: #{quote(fk.on_delete)})"
  end
end

def up
  with_lock_retries do
    remove_foreign_key_if_exists(:backup_labels, :projects)
    remove_foreign_key_if_exists(:backup_labels, :namespaces)
  end
end

def down
  add_concurrent_foreign_key(:backup_labels, :projects, column: :project_id, on_delete: :cascade)
  add_concurrent_foreign_key(:backup_labels, :namespaces, column: :group_id, on_delete: :cascade)
end

File.open("db/migrate/20211201000001_drop_ci_foreign_keys.rb", "wb") do |file|
  file.write <<-EOS.strip_heredoc
    # frozen_string_literal: true

    class DropCiForeignKeys < ActiveRecord::Migration[6.1]
      include Gitlab::Database::MigrationHelpers

      DOWNTIME = false

      disable_ddl_transaction!

      def up
        #{emit_up(invalid_foreign_keys).join("\n        ")}
      end

      def down
        #{emit_down(invalid_foreign_keys).join("\n        ")}
      end
    end
  EOS
end
