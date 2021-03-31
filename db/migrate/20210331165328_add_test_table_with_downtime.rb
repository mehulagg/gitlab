# frozen_string_literal: true

class AddTestTableWithDowntime < ActiveRecord::Migration[6.0]
  DOWNTIME = true
  DOWNTIME_REASON = 'why not?'

  def change
    create_table :foo do |t|
      t.text    :name
      t.bigint  :status
      t.timestamps_with_timezone null: false
    end
  end
end
