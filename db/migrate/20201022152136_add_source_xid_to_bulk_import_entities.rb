# frozen_string_literal: true

class AddSourceXidToBulkImportEntities < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :bulk_import_entities, :source_xid, :integer
  end
end
