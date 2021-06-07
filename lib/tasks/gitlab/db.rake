# frozen_string_literal: true

namespace :gitlab do
  namespace :db do
    desc 'GitLab | DB | Manually insert schema migration version'
    task :mark_migration_complete, [:version] => :environment do |_, args|
      unless args[:version]
        puts "Must specify a migration version as an argument".color(:red)
        exit 1
      end

      version = args[:version].to_i
      if version == 0
        puts "Version '#{args[:version]}' must be a non-zero integer".color(:red)
        exit 1
      end

      sql = "INSERT INTO schema_migrations (version) VALUES (#{version})"
      begin
        ActiveRecord::Base.connection.execute(sql)
        puts "Successfully marked '#{version}' as complete".color(:green)
      rescue ActiveRecord::RecordNotUnique
        puts "Migration version '#{version}' is already marked complete".color(:yellow)
      end
    end

    desc 'GitLab | DB | Drop all tables'
    task drop_tables: :environment do
      connection = ActiveRecord::Base.connection

      # In PostgreSQLAdapter, data_sources returns both views and tables, so use
      # #tables instead
      tables = connection.tables

      # Removes the entry from the array
      tables.delete 'schema_migrations'
      # Truncate schema_migrations to ensure migrations re-run
      connection.execute('TRUNCATE schema_migrations') if connection.table_exists? 'schema_migrations'

      # Drop any views
      connection.views.each do |view|
        connection.execute("DROP VIEW IF EXISTS #{connection.quote_table_name(view)} CASCADE")
      end

      # Drop tables with cascade to avoid dependent table errors
      # PG: http://www.postgresql.org/docs/current/static/ddl-depend.html
      # Add `IF EXISTS` because cascade could have already deleted a table.
      tables.each { |t| connection.execute("DROP TABLE IF EXISTS #{connection.quote_table_name(t)} CASCADE") }

      # Drop all extra schema objects GitLab owns
      Gitlab::Database::EXTRA_SCHEMAS.each do |schema|
        connection.execute("DROP SCHEMA IF EXISTS #{connection.quote_table_name(schema)}")
      end
    end

    desc 'GitLab | DB | Configures the database by running migrate, or by loading the schema and seeding if needed'
    task configure: :environment do
      # Check if we have existing db tables
      # The schema_migrations table will still exist if drop_tables was called
      if ActiveRecord::Base.connection.tables.count > 1
        Rake::Task['db:migrate'].invoke
      else
        # Add post-migrate paths to ensure we mark all migrations as up
        Gitlab::Database.add_post_migrate_path_to_rails(force: true)
        Rake::Task['db:structure:load'].invoke
        Rake::Task['db:seed_fu'].invoke
      end
    end

    desc 'GitLab | DB | Run database migrations and print `unattended_migrations_completed` if action taken'
    task unattended: :environment do
      no_database = !ActiveRecord::Base.connection.schema_migration.table_exists?
      needs_migrations = ActiveRecord::Base.connection.migration_context.needs_migration?

      if no_database || needs_migrations
        Rake::Task['gitlab:db:configure'].invoke
        puts "unattended_migrations_completed"
      else
        puts "unattended_migrations_static"
      end
    end

    desc 'GitLab | DB | Sets up EE specific database functionality'

    if Gitlab.ee?
      task setup_ee: %w[geo:db:drop geo:db:create geo:db:schema:load geo:db:migrate]
    else
      task :setup_ee
    end

    desc 'This adjusts and cleans db/structure.sql - it runs after db:structure:dump'
    task :clean_structure_sql do |task_name|
      structure_file = 'db/structure.sql'
      schema = File.read(structure_file)

      File.open(structure_file, 'wb+') do |io|
        Gitlab::Database::SchemaCleaner.new(schema).clean(io)
      end

      # Allow this task to be called multiple times, as happens when running db:migrate:redo
      Rake::Task[task_name].reenable
    end

    desc 'This dumps GitLab specific database details - it runs after db:structure:dump'
    task :dump_custom_structure do |task_name|
      Gitlab::Database::CustomStructure.new.dump

      # Allow this task to be called multiple times, as happens when running db:migrate:redo
      Rake::Task[task_name].reenable
    end

    desc 'This loads GitLab specific database details - runs after db:structure:dump'
    task :load_custom_structure do
      configuration = Rails.application.config_for(:database)

      ENV['PGHOST']     = configuration['host']          if configuration['host']
      ENV['PGPORT']     = configuration['port'].to_s     if configuration['port']
      ENV['PGPASSWORD'] = configuration['password'].to_s if configuration['password']
      ENV['PGUSER']     = configuration['username'].to_s if configuration['username']

      command = 'psql'
      dump_filepath = Gitlab::Database::CustomStructure.custom_dump_filepath.to_path
      args = ['-v', 'ON_ERROR_STOP=1', '-q', '-X', '-f', dump_filepath, configuration['database']]

      unless Kernel.system(command, *args)
        raise "failed to execute:\n#{command} #{args.join(' ')}\n\n" \
          "Please ensure `#{command}` is installed in your PATH and has proper permissions.\n\n"
      end
    end

    # Inform Rake that custom tasks should be run every time rake db:structure:dump is run
    #
    # Rails 6.1 deprecates db:structure:dump in favor of db:schema:dump
    Rake::Task['db:structure:dump'].enhance do
      Rake::Task['gitlab:db:clean_structure_sql'].invoke
      Rake::Task['gitlab:db:dump_custom_structure'].invoke
    end

    # Inform Rake that custom tasks should be run every time rake db:schema:dump is run
    Rake::Task['db:schema:dump'].enhance do
      Rake::Task['gitlab:db:clean_structure_sql'].invoke
      Rake::Task['gitlab:db:dump_custom_structure'].invoke
    end

    # Inform Rake that custom tasks should be run every time rake db:structure:load is run
    #
    # Rails 6.1 deprecates db:structure:load in favor of db:schema:load
    Rake::Task['db:structure:load'].enhance do
      Rake::Task['gitlab:db:load_custom_structure'].invoke
    end

    # Inform Rake that custom tasks should be run every time rake db:schema:load is run
    Rake::Task['db:schema:load'].enhance do
      Rake::Task['gitlab:db:load_custom_structure'].invoke
    end

    desc 'Create missing dynamic database partitions'
    task :create_dynamic_partitions do
      Gitlab::Database::Partitioning::PartitionCreator.new.create_partitions
    end

    # This is targeted towards deploys and upgrades of GitLab.
    # Since we're running migrations already at this time,
    # we also check and create partitions as needed here.
    Rake::Task['db:migrate'].enhance do
      Rake::Task['gitlab:db:create_dynamic_partitions'].invoke
    end

    # When we load the database schema from db/structure.sql
    # we don't have any dynamic partitions created. We don't really need to
    # because application initializers/sidekiq take care of that, too.
    # However, the presence of partitions for a table has influence on their
    # position in db/structure.sql (which is topologically sorted).
    #
    # Other than that it's helpful to create partitions early when bootstrapping
    # a new installation.
    #
    # Rails 6.1 deprecates db:structure:load in favor of db:schema:load
    Rake::Task['db:structure:load'].enhance do
      Rake::Task['gitlab:db:create_dynamic_partitions'].invoke
    end

    Rake::Task['db:schema:load'].enhance do
      Rake::Task['gitlab:db:create_dynamic_partitions'].invoke
    end

    # During testing, db:test:load restores the database schema from scratch
    # which does not include dynamic partitions. We cannot rely on application
    # initializers here as the application can continue to run while
    # a rake task reloads the database schema.
    Rake::Task['db:test:load'].enhance do
      Rake::Task['gitlab:db:create_dynamic_partitions'].invoke
    end

    desc 'reindex a regular (non-unique) index without downtime to eliminate bloat'
    task :reindex, [:index_name] => :environment do |_, args|
      unless Feature.enabled?(:database_reindexing, type: :ops)
        puts "This feature (database_reindexing) is currently disabled.".color(:yellow)
        exit
      end

      indexes = Gitlab::Database::Reindexing.candidate_indexes

      if identifier = args[:index_name]
        raise ArgumentError, "Index name is not fully qualified with a schema: #{identifier}" unless identifier =~ /^\w+\.\w+$/

        indexes = indexes.where(identifier: identifier)

        raise "Index not found or not supported: #{args[:index_name]}" if indexes.empty?
      end

      ActiveRecord::Base.logger = Logger.new(STDOUT) if Gitlab::Utils.to_boolean(ENV['LOG_QUERIES_TO_CONSOLE'], default: false)

      Gitlab::Database::Reindexing.perform(indexes)
    rescue StandardError => e
      Gitlab::AppLogger.error(e)
      raise
    end

    desc 'Check if there have been user additions to the database'
    task active: :environment do
      if ActiveRecord::Base.connection.migration_context.needs_migration?
        puts "Migrations pending. Database not active"
        exit 1
      end

      # A list of projects that GitLab creates automatically on install/upgrade
      # gc = Gitlab::CurrentSettings.current_application_settings
      seed_projects = [Gitlab::CurrentSettings.current_application_settings.self_monitoring_project]

      if (Project.count - seed_projects.count {|x| !x.nil? }).eql?(0)
        puts "No user created projects. Database not active"
        exit 1
      end

      puts "Found user created projects. Database active"
      exit 0
    end

    desc 'Run migrations with instrumentation'
    task migration_testing: :environment do
      result_dir = Gitlab::Database::Migrations::Instrumentation::RESULT_DIR
      raise "Directory exists already, won't overwrite: #{result_dir}" if File.exist?(result_dir)

      Dir.mkdir(result_dir)

      verbose_was = ActiveRecord::Migration.verbose
      ActiveRecord::Migration.verbose = true

      ctx = ActiveRecord::Base.connection.migration_context
      existing_versions = ctx.get_all_versions.to_set

      pending_migrations = ctx.migrations.reject do |migration|
        existing_versions.include?(migration.version)
      end

      instrumentation = Gitlab::Database::Migrations::Instrumentation.new

      pending_migrations.each do |migration|
        instrumentation.observe(migration.version) do
          ActiveRecord::Migrator.new(:up, ctx.migrations, ctx.schema_migration, migration.version).run
        end
      end
    ensure
      if instrumentation
        File.open(File.join(result_dir, Gitlab::Database::Migrations::Instrumentation::STATS_FILENAME), 'wb+') do |io|
          io << instrumentation.observations.to_json
        end
      end

      ActiveRecord::Base.clear_cache!
      ActiveRecord::Migration.verbose = verbose_was
    end

    desc 'Run all pending batched migrations'
    task execute_batched_migrations: :environment do
      Gitlab::Database::BackgroundMigration::BatchedMigration.active.queue_order.each do |migration|
        Gitlab::AppLogger.info("Executing batched migration #{migration.id} inline")
        Gitlab::Database::BackgroundMigration::BatchedMigrationRunner.new.run_entire_migration(migration)
      end
    end

    # Only for development environments,
    # we execute pending data migrations inline for convenience.
    Rake::Task['db:migrate'].enhance do
      Rake::Task['gitlab:db:execute_batched_migrations'].invoke if Rails.env.development?
    end

    class TableOwnershipDetector

      attr_reader :tables, :current_migration

      def initialize
        @tables = {}
      end

      def execute_migrations
        ctx = ActiveRecord::Base.connection.migration_context
        existing_versions = ctx.get_all_versions.to_set

        pending_migrations = ctx.migrations.reject do |migration|
          existing_versions.include?(migration.version)
        end

        pending_migrations.each do |migration|
          @current_migration = migration.version
          ActiveRecord::Migrator.new(:up, ctx.migrations, ctx.schema_migration, migration.version).run
        end
      end

      def collect_table_owner(table)
        (@tables[table] ||= []) << @current_migration
      end
    end

    task table_ownership: :environment do
      detector = TableOwnershipDetector.new

      ActiveSupport::Notifications.subscribe('sql.active_record') do |event|
        payload = event.payload

        if payload[:sql] =~ /^(ALTER|CREATE) TABLE "([^"]+)"/
          detector.collect_table_owner($2)
        elsif payload[:sql] =~ /^(CREATE|DROP) INDEX CONCURRENTLY "[^"]+" ON "([^"]+)"/
          detector.collect_table_owner($2)
        end
      end

      detector.execute_migrations

      # detector.tables examples:
      # "iterations_cadences"=>[20201228110136, 20201228110136, 20210427194958, 20210427194958],
      # "onboarding_progresses"=>[20201230180202, 20210114142443, 20210114142443, 20210114142443, 20210114142443, 20210208103243],
      # "dast_profiles"=>[20210111051045, 20210111051045, 20210223053451],
      # "packages_composer_cache_files"=>[20210112202949, 20210112202949, 20210203222620, 20210203223551],
      # "group_repository_storage_moves"=>[20210115090452],
      # "analytics_devops_adoption_segments"=>[20210121100038, 20210121121102, 20210430124212, 20210430130259, 20210521073920],
      # "dependency_proxy_manifests"=>[20210128140157],
      # "batched_background_migrations"=>[20210128172149, 20210128172149, 20210308190413, 20210406140057, 20210413155324],
      # "batched_background_migration_jobs"=>[20210128172149, 20210311120152, 20210414045322, 20210427062807, 20210427094931],
      # "packages_rubygems_metadata"=>[20210203221631, 20210203221631],
      # "external_approval_rules"=>[20210209110019],
      # "external_approval_rules_protected_branches"=>[20210209110019],
      # "security_orchestration_policy_configurations"=>[20210209160510, 20210302160544, 20210412172030],
      # "boards_epic_list_user_preferences"=>[20210217101901],
      # "backup_labels"=>[20210222185538, 20210222185538],
      # "dast_site_profile_secret_variables"=>[20210305031822, 20210305031822],
      # "ci_unit_tests"=>[20210305180331],
      # "ci_unit_test_failures"=>[20210305182855],
      # "web_hook_logs_part_0c5294f417"=>[20210306121300, 20210306121300, 20210306121300, 20210306121300, 20210413130011],
      # "packages_helm_file_metadata"=>[20210316171009, 20210316171009],
      # "dast_profiles_pipelines"=>[20210317035357],
      # "elastic_index_settings"=>[20210317100520, 20210317100520],
      # "in_product_marketing_emails"=>[20210317104301],
      # "status_check_responses"=>[20210323125809, 20210510083845],
      # "vulnerability_finding_evidences"=>[20210326190903, 20210326190903],

      # next step:
      # for each version/migration, find the associated MR and its group label
      # generate ownership migration

      binding.pry

      exit 0
    end
  end
end
