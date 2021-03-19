# frozen_string_literal: true

class SetResyncFlagForRetriedProjects < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      UPDATE project_registry SET resync_repository = 't' WHERE repository_retry_count > 0 AND resync_repository = 'f';
      UPDATE project_registry SET resync_wiki = 't' WHERE wiki_retry_count > 0 AND resync_wiki = 'f';
    SQL
  end
end
