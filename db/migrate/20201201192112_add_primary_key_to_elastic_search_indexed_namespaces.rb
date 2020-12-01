# frozen_string_literal: true

class AddPrimaryKeyToElasticSearchIndexedNamespaces < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  UNIQUE_INDEX_NAME = 'index_elasticsearch_indexed_namespaces_on_namespace_id'
  PRIMARY_KEY_NAME = 'elasticsearch_indexed_namespaces_pkey'

  disable_ddl_transaction!

  def up
    transaction do
      execute(<<~SQL)
        DELETE FROM elasticsearch_indexed_namespaces
        WHERE namespace_id IS NULL;
      SQL

      execute(<<~SQL)
        ALTER TABLE elasticsearch_indexed_namespaces
        ALTER COLUMN namespace_id SET NOT NULL;
      SQL

      execute(<<~SQL)
        ALTER TABLE elasticsearch_indexed_namespaces
        ADD CONSTRAINT #{PRIMARY_KEY_NAME}
        PRIMARY KEY USING INDEX #{UNIQUE_INDEX_NAME};
      SQL
    end
  end

  def down
    add_concurrent_index :elasticsearch_indexed_namespaces, :namespace_id, unique: true, name: UNIQUE_INDEX_NAME

    transaction do
      execute(<<~SQL)
        ALTER TABLE elasticsearch_indexed_namespaces
        DROP CONSTRAINT #{PRIMARY_KEY_NAME};
      SQL

      execute(<<~SQL)
        ALTER TABLE elasticsearch_indexed_namespaces
        ALTER COLUMN namespace_id DROP NOT NULL;
      SQL
    end
  end
end
