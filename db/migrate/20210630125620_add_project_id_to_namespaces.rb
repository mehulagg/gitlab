# frozen_string_literal: true

class AddProjectIdToNamespaces < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    add_column :namespaces, :project_id, :integer

    with_lock_retries do
      add_foreign_key :namespaces, :projects, column: :project_id
    end
  end

  def down
    # TODO
  end
end
