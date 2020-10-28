# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ChangeClustersHelmMajorVersionDefaultTo3 < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_column_default(:clusters, :helm_major_version, from: 2, to: 3)
  end
end
