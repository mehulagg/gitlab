class BuildUserContributedProjectsTable < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  BATCH_SIZE = 100000
  SLEEP_TIME = 30

  def up
    with_index(:events, [:author_id, :project_id], name: 'events_user_contributions_temp', where: 'project_id IS NOT NULL') do
      iteration = 0
      records = 0
      begin
        Rails.logger.info "Building user_contributed_projects table, batch ##{iteration}"
        result = execute <<~SQL
          INSERT INTO user_contributed_projects (user_id, project_id)
          SELECT e.user_id, e.project_id
          FROM (SELECT DISTINCT author_id AS user_id, project_id FROM events WHERE project_id IS NOT NULL) AS e
          LEFT JOIN user_contributed_projects ucp USING (user_id, project_id)
          WHERE ucp.user_id IS NULL
          LIMIT #{BATCH_SIZE}
        SQL
        iteration += 1
        records += result.cmd_tuples
        Rails.logger.info "Building user_contributed_projects table, batch ##{iteration} complete, created #{records} overall"
        Kernel.sleep(SLEEP_TIME) if result.cmd_tuples > 0
      end while result.cmd_tuples > 0
    end

    execute "ANALYZE user_contributed_projects" if Gitlab::Database.postgresql?
  end

  def down
    execute "TRUNCATE user_contributed_projects"
  end

  private

  def with_index(*args)
    add_concurrent_index(*args) unless index_exists?(*args)
    yield
  ensure
    remove_concurrent_index(*args) if index_exists?(*args)
  end
end
