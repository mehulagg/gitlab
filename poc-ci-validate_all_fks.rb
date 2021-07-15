# frozen_string_literal: true

connection = ApplicationRecord.connection
invalid_foreign_keys = nil

Dir.glob('app/models/ci/**/*.rb').each { |f| require_relative(f) rescue nil }
Dir.glob('ee/app/models/ci/**/*.rb').each { |f| require_relative(f) rescue nil }
gitlab_ci_tables = Ci::ApplicationRecord.descendants.map(&:table_name).uniq.sort
gitlab_ci_tables += %w[tags taggings ci_test_cases ci_test_case_failures]

gitlab_shared_tables = [
  "schema_migrations",
  "background_migration_jobs",
  "batched_background_migration_jobs",
  "batched_background_migrations"
].sort

public_tables = (ApplicationRecord.connection.tables - gitlab_ci_tables - gitlab_shared_tables).sort

invalid_foreign_keys = [gitlab_ci_tables, public_tables, gitlab_shared_tables].flat_map do |tables|
  connection.transaction(requires_new: true) do
    tables.flat_map do |table_name|
      connection.foreign_keys(table_name).reject { |fk| tables.include?(fk.to_table) }
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
