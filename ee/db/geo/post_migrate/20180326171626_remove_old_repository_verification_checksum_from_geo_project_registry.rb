# frozen_string_literal: true

class RemoveOldRepositoryVerificationChecksumFromGeoProjectRegistry < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  def up
    remove_column :project_registry, :repository_verification_checksum
    remove_column :project_registry, :wiki_verification_checksum
  end

  def down
    add_column :project_registry, :repository_verification_checksum, :string
    add_column :project_registry, :wiki_verification_checksum, :string
  end
end
