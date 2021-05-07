# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreatePackagesPushes < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'uniq_packages_pushes_on_sha'

  def up
    unless table_exists?(:packages_pushes)
      create_table :packages_pushes do |t|
        t.references :package_file,
                     foreign_key: { to_table: :packages_package_files, on_delete: :cascade },
                     null: false,
                     index: true
        t.text :sha, null: false, index: false
        t.timestamps_with_timezone

        t.index :sha,
                name: INDEX_NAME,
                unique: true,
                using: :btree
      end
    end

    add_text_limit :packages_pushes, :sha, 255
  end

  def down
    drop_table(:packages_pushes)
  end
end
