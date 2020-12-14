# frozen_string_literal: true

class AddHasExternalWikiTrigger < ActiveRecord::Migration[6.0]
  include Gitlab::Database::SchemaHelpers

  DOWNTIME = false
  TRIGGER_FUNCTION_NAME = 'set_external_wiki'

  def up
    create_trigger_function(TRIGGER_FUNCTION_NAME, replace: true) do
      <<~SQL
        UPDATE projects SET has_external_wiki = COALESCE(NEW.active, FALSE)
        WHERE projects.id = COALESCE(NEW.project_id, OLD.project_id);
        RETURN NEW;
      SQL
    end

    execute(<<~SQL)
      CREATE TRIGGER trigger_has_external_wiki_on_insert
      AFTER INSERT ON services
      FOR EACH ROW
      WHEN (NEW.type = 'ExternalWikiService' AND NEW.project_id IS NOT NULL)
      EXECUTE FUNCTION #{TRIGGER_FUNCTION_NAME}();
    SQL

    execute(<<~SQL)
      CREATE TRIGGER trigger_has_external_wiki_on_update
      AFTER UPDATE ON services
      FOR EACH ROW
      WHEN (NEW.type = 'ExternalWikiService' AND OLD.active != NEW.active AND NEW.project_id IS NOT NULL)
      EXECUTE FUNCTION #{TRIGGER_FUNCTION_NAME}();
    SQL

    execute(<<~SQL)
      CREATE TRIGGER trigger_has_external_wiki_on_delete
      AFTER DELETE ON services
      FOR EACH ROW
      WHEN (OLD.type = 'ExternalWikiService' AND OLD.project_id IS NOT NULL)
      EXECUTE FUNCTION #{TRIGGER_FUNCTION_NAME}();
    SQL
  end

  def down
    execute(<<~SQL)
      DROP TRIGGER trigger_has_external_wiki_on_insert ON services;
    SQL

    execute(<<~SQL)
      DROP TRIGGER trigger_has_external_wiki_on_update ON services;
    SQL

    execute(<<~SQL)
      DROP TRIGGER trigger_has_external_wiki_on_delete ON services;
    SQL

    execute(<<~SQL)
      DROP FUNCTION #{TRIGGER_FUNCTION_NAME};
    SQL
  end
end
