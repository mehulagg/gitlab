class CreateBranchMirrors < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :branch_mirrors do |t|
      t.references :project, index: true, null: false, foreign_key: { to_table: :projects, on_delete: :cascade }, type: :integer

      t.timestamps
      t.datetime :last_successfully_mirrored_at, null: true

      t.string :from_branch, null: false
      t.string :to_branch, null: false
    end
  end
end
