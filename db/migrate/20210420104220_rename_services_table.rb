# frozen_string_literal: true

class RenameServicesTable < ActiveRecord::Migration[6.0]
  def up
    with_lock_retries do
      rename_table(:services, :integrations)
      execute('CREATE VIEW services AS SELECT * FROM integrations')
    end
  end

  def down
    with_lock_retries do
      execute('DROP VIEW IF EXISTS services')
      rename_table(:integrations, :services)
    end
  end
end
