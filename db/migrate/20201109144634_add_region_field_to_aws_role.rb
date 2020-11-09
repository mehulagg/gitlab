# frozen_string_literal: true

class AddRegionFieldToAwsRole < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :aws_roles, :region, :text
    add_text_limit :aws_roles, :region, 255
  end

  def down
    remove_text_limit :aws_roles, :region
    remove_column :aws_roles, :region
  end
end
