# frozen_string_literal: true

class AddIndexForComposerPackages < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  INDEX_NAME = 'index_packages_on_project_id_name_when_composer'

  disable_ddl_transaction!

  def up
    add_concurrent_index :packages_packages, [:project_id, :name], where: "package_type = #{Packages::Package.package_types[:composer]}", name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name(:packages_packages, INDEX_NAME)
  end
end
