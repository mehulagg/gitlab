# frozen_string_literal: true

class RemoveNamespacePlanId < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    remove_column :namespaces, :plan_id
  end

  def down
    add_column :namespaces, :plan_id, :integer
  end
end
