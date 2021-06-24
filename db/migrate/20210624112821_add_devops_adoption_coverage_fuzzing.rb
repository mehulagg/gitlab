# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddDevopsAdoptionCoverageFuzzing < ActiveRecord::Migration[6.1]
  def change
    add_column :analytics_devops_adoption_snapshots, :coverage_fuzzing_enabled_count, :integer
  end
end
