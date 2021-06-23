# frozen_string_literal: true

class AddPresentOnDefaultBranchToVulnerabilities < ActiveRecord::Migration[6.1]
  def change
    add_column :vulnerabilities, :present_on_default_branch, :boolean, default: true, null: false
  end
end
