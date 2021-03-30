# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddNewTrailPlans < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute "INSERT INTO plans (name, title, created_at, updated_at) VALUES ('premium-trial', 'Premium Trial', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    execute "INSERT INTO plans (name, title, created_at, updated_at) VALUES ('ultimate-trial', 'Ultimate Trial', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  end

  def down
    execute "DELETE FROM plans WHERE name IN ('premium-trial', 'ultimate-trial')"
  end
end
