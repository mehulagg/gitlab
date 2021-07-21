# frozen_string_literal: true

class AddTriggersToIntegrationsTypeNew < ActiveRecord::Migration[6.1]
  include Gitlab::Database::SchemaHelpers

  FUNCTION_NAME = 'integrations_set_type_new'
  TRIGGER_ON_INSERT_NAME = 'trigger_type_new_on_insert'
  TRIGGER_ON_UPDATE_NAME = 'trigger_type_new_on_update'

  def up
    create_trigger_function(FUNCTION_NAME, replace: true) do
      <<~SQL
        UPDATE integrations SET type_new = concat('Integrations::', replace(NEW.type, 'Service', ''))
        WHERE integrations.id = NEW.id;
        RETURN NULL;
      SQL
    end

    execute(<<~SQL)
      CREATE TRIGGER #{TRIGGER_ON_INSERT_NAME}
      AFTER INSERT ON integrations
      FOR EACH ROW
      WHEN (pg_trigger_depth() = 0) -- prevent recursion
      EXECUTE FUNCTION #{FUNCTION_NAME}();
    SQL

    execute(<<~SQL)
      CREATE TRIGGER #{TRIGGER_ON_UPDATE_NAME}
      AFTER UPDATE ON integrations
      FOR EACH ROW
      WHEN (pg_trigger_depth() = 0) -- prevent recursion
      EXECUTE FUNCTION #{FUNCTION_NAME}();
    SQL
  end

  def down
    drop_trigger(:integrations, TRIGGER_ON_INSERT_NAME)
    drop_trigger(:integrations, TRIGGER_ON_UPDATE_NAME)
    drop_function(FUNCTION_NAME)
  end
end
