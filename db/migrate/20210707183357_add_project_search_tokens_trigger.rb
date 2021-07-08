# frozen_string_literal: true

class AddProjectSearchTokensTrigger < ActiveRecord::Migration[6.1]
  include Gitlab::Database::SchemaHelpers

  FUNCTION_NAME = 'projects_search_tokens'
  TABLE_NAME = 'project_search_tokens'
  TRIGGER_NAME = 'trigger_project_search_tokens_on_insert_or_update'
  TRIGGER_TABLE_NAME = 'projects'

  def up
    create_trigger_function(FUNCTION_NAME, replace: true) do
      <<~SQL
        IF (TG_OP = 'INSERT') THEN
          INSERT INTO #{TABLE_NAME} (project_id, tokens)
          VALUES (NEW.id, (setweight(to_tsvector(NEW.path), 'A') || setweight(to_tsvector(NEW.name), 'B')));
        ELSEIF (TG_OP = 'UPDATE') THEN
          UPDATE #{TABLE_NAME}
          SET (tokens) = (setweight(to_tsvector(NEW.path), 'A') || setweight(to_tsvector(NEW.name), 'B'))
          WHERE project_id = NEW.id;
        END IF;
        RETURN NULL;
      SQL
    end

    create_trigger(TRIGGER_TABLE_NAME, TRIGGER_NAME, FUNCTION_NAME, fires: 'AFTER INSERT OR UPDATE')
  end

  def down
    drop_trigger(TRIGGER_TABLE_NAME, TRIGGER_NAME)
    drop_function(FUNCTION_NAME)
  end
end
