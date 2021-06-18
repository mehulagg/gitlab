# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddHealthStatusIdToLists < ActiveRecord::Migration[6.1]
  def up
    add_column :lists, :health_status_id, :smallint
  end
end
