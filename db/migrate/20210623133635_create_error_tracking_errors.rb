class CreateErrorTrackingErrors < ActiveRecord::Migration[6.1]
  def change
    create_table :error_tracking_errors do |t|
      t.reference :project
      t.string :name
      t.text :description
      t.string :actor
      t.datetime :first_seen_at
      t.datetime :last_seen_at
      t.string :platform

      t.timestamps
    end
  end
end
