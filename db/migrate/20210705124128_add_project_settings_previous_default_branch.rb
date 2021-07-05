# frozen_string_literal: true

class AddProjectSettingsPreviousDefaultBranch < ActiveRecord::Migration[6.1]
  def change
    add_column :project_settings, :previous_default_branch, :string
  end
end
