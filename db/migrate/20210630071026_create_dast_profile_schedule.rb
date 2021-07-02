# frozen_string_literal: true

class CreateDastProfileSchedule < ActiveRecord::Migration[6.1]
  DOWNTIME = false

  def change
    table_comment = {
    }

    create_table :dast_profile_schedules, comment: table_comment.to_json do |t|
      t.bigint :dast_profile_id, null: false
      t.bigint :owner_id
      t.datetime :next_run_at
      t.text :cron
      t.text :cron_timezone
      t.boolean :active, default: true
      t.timestamps null: false
    end
  end
end
