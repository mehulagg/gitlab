# frozen_string_literal: true

class AddOptionalToCiBuildNeeds < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :ci_build_needs, :optional, :boolean, default: false, null: false
  end
end
