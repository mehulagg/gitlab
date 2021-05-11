# frozen_string_literal: true

class AddTraversalIdsParentIdConstraint < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute(<<~SQL)
      ALTER TABLE namespaces
      ADD CONSTRAINT traversal_ids_id CHECK (
        array_length(traversal_ids, 1) >= 1 AND
        id = traversal_ids[array_length(traversal_ids, 1)]
      )
    SQL
    # Once we remove the feature flag the first part of the constraint should be:
    #   parent_id IS NULL AND traversal_ids = ARRAY[id]
    #   instead of just
    #   parent_id IS NULL
    execute(<<~SQL)
      ALTER TABLE namespaces
      ADD CONSTRAINT traversal_ids_parent_id CHECK (
        (
          parent_id IS NULL
        ) OR (
          parent_id IS NOT NULL AND
          array_length(traversal_ids, 1) >= 2 AND
          parent_id = traversal_ids[array_length(traversal_ids, 1)-1]
        )
      )
    SQL
  end

  def down
    execute "ALTER TABLE namespaces DROP CONSTRAINT traversal_ids_id"
    execute "ALTER TABLE namespaces DROP CONSTRAINT traversal_ids_parent_id"
  end
end
