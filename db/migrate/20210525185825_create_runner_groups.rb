class CreateRunnerGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :runner_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
