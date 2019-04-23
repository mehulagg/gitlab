# rubocop:disable all
class AddProjectMergeApproves < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :approvals_before_merge, :integer, null: false, default: 0
  end
end
