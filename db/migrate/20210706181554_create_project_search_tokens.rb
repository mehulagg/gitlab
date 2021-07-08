# frozen_string_literal: true

class CreateProjectSearchTokens < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    with_lock_retries do
      execute(<<~SQL)
      CREATE TABLE project_search_tokens (
        project_id bigint PRIMARY KEY,
        tokens tsvector,
        CONSTRAINT fk_project
          FOREIGN KEY(project_id)
            REFERENCES projects(id));
      SQL
    end
  end

  def down
    with_lock_retries do
      drop_table :project_search_tokens
    end
  end
end
