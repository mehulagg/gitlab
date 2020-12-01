# frozen_string_literal: true

class AddPrimaryKeyToElasticSearchIndexedProjects < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  UNIQUE_INDEX_NAME = 'index_elasticsearch_indexed_projects_on_project_id'
  PRIMARY_KEY_NAME = 'elasticsearch_indexed_projects_pkey'

  def up
    execute(<<~SQL)
      DELETE FROM elasticsearch_indexed_projects
      WHERE project_id IS NULL;

      ALTER TABLE elasticsearch_indexed_projects
      ALTER COLUMN project_id SET NOT NULL;

      ALTER TABLE elasticsearch_indexed_projects
      ADD CONSTRAINT #{PRIMARY_KEY_NAME}
      PRIMARY KEY USING INDEX #{UNIQUE_INDEX_NAME};
    SQL
  end

  def down
    # rubocop:disable Migration/AddIndex
    add_index :elasticsearch_indexed_projects, :project_id, unique: true,
      name: 'index_elasticsearch_indexed_projects_on_project_id'
    # rubocop:enable Migration/AddIndex

    execute(<<~SQL)
      ALTER TABLE elasticsearch_indexed_projects
      DROP CONSTRAINT #{PRIMARY_KEY_NAME};

      ALTER TABLE elasticsearch_indexed_projects
      ALTER COLUMN project_id DROP NOT NULL;
    SQL
  end
end
