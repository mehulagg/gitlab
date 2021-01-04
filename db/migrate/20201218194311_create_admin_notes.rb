class CreateAdminNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_notes do |t|
      t.references :namespace, foreign_key: true
      t.text :note

      t.timestamps
    end
  end
end
