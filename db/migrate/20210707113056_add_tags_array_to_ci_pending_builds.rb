# frozen_string_literal: true

class AddTagsArrayToCiPendingBuilds < ActiveRecord::Migration[6.1]
  def change
    add_column :ci_pending_builds, :tags, :bigint, array: true
  end
end
