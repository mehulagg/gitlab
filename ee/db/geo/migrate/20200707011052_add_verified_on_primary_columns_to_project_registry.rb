# frozen_string_literal: true

class AddVerifiedOnPrimaryColumnsToProjectRegistry < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :project_registry, :primary_repository_checksummed, :boolean, default: false, null: false
    add_column :project_registry, :primary_wiki_checksummed, :boolean, default: false, null: false
  end
end
