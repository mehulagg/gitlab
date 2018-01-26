# rubocop:disable Migration/Timestamps
class CreateHistoricalData < ActiveRecord::Migration
  DOWNTIME = false

  def change
    create_table :historical_data do |t|
      t.date :date, null: false
      t.integer :active_user_count

      t.timestamps null: true
    end
  end
end
