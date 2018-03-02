class BuildUserInteractedProjectsTable < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if Gitlab::Database.postgresql?
      PostgresStrategy.new
    else
      MysqlStrategy.new
    end.up

    add_concurrent_index :user_interacted_projects, [:project_id, :user_id], unique: true

    add_concurrent_foreign_key :user_interacted_projects, :users, column: :user_id, on_delete: :cascade
    add_concurrent_foreign_key :user_interacted_projects, :projects, column: :project_id, on_delete: :cascade
  end

  def down
    execute "TRUNCATE user_interacted_projects"

    remove_foreign_key :user_interacted_projects, :users
    remove_foreign_key :user_interacted_projects, :projects

    remove_concurrent_index_by_name :user_interacted_projects, 'index_user_interacted_projects_on_project_id_and_user_id'
  end

  private

  class PostgresStrategy < ActiveRecord::Migration
    include Gitlab::Database::MigrationHelpers

    BATCH_SIZE = 100_000
    SLEEP_TIME = 5

    def up
      with_index(:events, [:author_id, :project_id], name: 'events_user_interactions_temp', where: 'project_id IS NOT NULL') do
        iteration = 0
        records = 0
        begin
          Rails.logger.info "Building user_interacted_projects table, batch ##{iteration}"
          result = execute <<~SQL
            INSERT INTO user_interacted_projects (user_id, project_id)
            SELECT e.user_id, e.project_id
            FROM (SELECT DISTINCT author_id AS user_id, project_id FROM events WHERE project_id IS NOT NULL) AS e
            LEFT JOIN user_interacted_projects ucp USING (user_id, project_id)
            WHERE ucp.user_id IS NULL
            LIMIT #{BATCH_SIZE}
          SQL
          iteration += 1
          records += result.cmd_tuples
          Rails.logger.info "Building user_interacted_projects table, batch ##{iteration} complete, created #{records} overall"
          Kernel.sleep(SLEEP_TIME) if result.cmd_tuples > 0
        rescue ActiveRecord::InvalidForeignKey => e
          Rails.logger.info "Retry on InvalidForeignKey: #{e}"
          retry
        end while result.cmd_tuples > 0
      end

      execute "ANALYZE user_interacted_projects"

    end

    private

    def with_index(*args)
      add_concurrent_index(*args) unless index_exists?(*args)
      yield
    ensure
      remove_concurrent_index(*args) if index_exists?(*args)
    end
  end

  class MysqlStrategy < ActiveRecord::Migration
    include Gitlab::Database::MigrationHelpers

    def up
      execute <<~SQL
        INSERT INTO user_interacted_projects (user_id, project_id)
        SELECT e.user_id, e.project_id
        FROM (SELECT DISTINCT author_id AS user_id, project_id FROM events WHERE project_id IS NOT NULL) AS e
        LEFT JOIN user_interacted_projects ucp USING (user_id, project_id)
        WHERE ucp.user_id IS NULL
      SQL
    end
  end

end
