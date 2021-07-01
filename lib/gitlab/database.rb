# frozen_string_literal: true

module Gitlab
  module Database
    CI_DATABASE_NAME = 'ci'

    # This constant is used when renaming tables concurrently.
    # If you plan to rename a table using the `rename_table_safely` method, add your table here one milestone before the rename.
    # Example:
    # TABLES_TO_BE_RENAMED = {
    #   'old_name' => 'new_name'
    # }.freeze
    TABLES_TO_BE_RENAMED = {
      'services' => 'integrations'
    }.freeze

    # Minimum PostgreSQL version requirement per documentation:
    # https://docs.gitlab.com/ee/install/requirements.html#postgresql-requirements
    MINIMUM_POSTGRES_VERSION = 12

    # https://www.postgresql.org/docs/9.2/static/datatype-numeric.html
    MAX_INT_VALUE = 2147483647
    MIN_INT_VALUE = -2147483648

    # The max value between MySQL's TIMESTAMP and PostgreSQL's timestampz:
    # https://www.postgresql.org/docs/9.1/static/datatype-datetime.html
    # https://dev.mysql.com/doc/refman/5.7/en/datetime.html
    # FIXME: this should just be the max value of timestampz
    MAX_TIMESTAMP_VALUE = Time.at((1 << 31) - 1).freeze

    # The maximum number of characters for text fields, to avoid DoS attacks via parsing huge text fields
    # https://gitlab.com/gitlab-org/gitlab-foss/issues/61974
    MAX_TEXT_SIZE_LIMIT = 1_000_000

    # Minimum schema version from which migrations are supported
    # Migrations before this version may have been removed
    MIN_SCHEMA_VERSION = 20190506135400
    MIN_SCHEMA_GITLAB_VERSION = '11.11.0'

    # Schema we store dynamically managed partitions in (e.g. for time partitioning)
    DYNAMIC_PARTITIONS_SCHEMA = :gitlab_partitions_dynamic

    # Schema we store static partitions in (e.g. for hash partitioning)
    STATIC_PARTITIONS_SCHEMA = :gitlab_partitions_static

    # This is an extensive list of postgres schemas owned by GitLab
    # It does not include the default public schema
    EXTRA_SCHEMAS = [DYNAMIC_PARTITIONS_SCHEMA, STATIC_PARTITIONS_SCHEMA].freeze

    DEFAULT_POOL_HEADROOM = 10

    DATABASES = {
      main: Database::Database.new(ActiveRecord::Base)
    }.freeze

    def self.main
      DATABASES[:main]
    end

    # TODO: remove
    def self.default_pool_size
      main.default_pool_size
    end

    # TODO: remove
    def self.config
      main.config
    end

    def self.has_config?(database_name)
      Gitlab::Application.config.database_configuration[Rails.env].include?(database_name.to_s)
    end

    def self.ci_database?(name)
      name == CI_DATABASE_NAME
    end

    # TODO: remove
    def self.username
      main.username
    end

    # TODO: remove
    def self.database_name
      main.database_name
    end

    # TODO: remove
    def self.adapter_name
      main.adapter_name
    end

    # TODO: remove
    def self.human_adapter_name
      main.human_adapter_name
    end

    # TODO: remove
    def self.disable_prepared_statements
      main.disable_prepared_statements
    end

    # TODO: remove
    def self.postgresql?
      main.postgresql?
    end

    # TODO: remove
    def self.read_only?
      main.read_only?
    end

    # TODO: remove
    def self.read_write?
      main.read_write?
    end

    # TODO: remove
    def self.db_read_only?
      main.db_read_only?
    end

    # TODO: remove
    def self.db_read_write?
      main.db_read_write?
    end

    # TODO: remove
    def self.version
      main.version
    end

    # TODO: remove
    def self.postgresql_minimum_supported_version?
      main.postgresql_minimum_supported_version?
    end

    # TODO: remove
    def self.check_postgres_version_and_print_warning
      main.check_postgres_version_and_print_warning
    end

    def self.nulls_order(field, direction = :asc, nulls_order = :nulls_last)
      raise ArgumentError unless [:nulls_last, :nulls_first].include?(nulls_order)
      raise ArgumentError unless [:asc, :desc].include?(direction)

      case nulls_order
      when :nulls_last then nulls_last_order(field, direction)
      when :nulls_first then nulls_first_order(field, direction)
      end
    end

    def self.nulls_last_order(field, direction = 'ASC')
      Arel.sql("#{field} #{direction} NULLS LAST")
    end

    def self.nulls_first_order(field, direction = 'ASC')
      Arel.sql("#{field} #{direction} NULLS FIRST")
    end

    def self.random
      "RANDOM()"
    end

    def self.true_value
      "'t'"
    end

    def self.false_value
      "'f'"
    end

    # TODO: remove
    def self.with_connection_pool(...)
      main.with_connection_pool(...)
    end

    # TODO: remove
    def self.bulk_insert(...)
      main.bulk_insert(...)
    end

    def self.sanitize_timestamp(timestamp)
      MAX_TIMESTAMP_VALUE > timestamp ? timestamp : MAX_TIMESTAMP_VALUE.dup
    end

    # TODO: remove
    def self.create_connection_pool(...)
      main.create_connection_pool(...)
    end

    # TODO: remove
    def self.connection
      main.connection
    end
    private_class_method :connection

    # TODO: remove
    def self.cached_column_exists?(...)
      main.cached_column_exists?(...)
    end

    # TODO: remove
    def self.cached_table_exists?(...)
      main.cached_table_exists?(...)
    end

    # TODO: remove
    def self.database_version
      main.database_version
    end
    private_class_method :database_version

    # TODO: remove
    def self.exists?
      main.exists?
    end

    # TODO: remove
    def self.system_id
      main.system_id
    end

    # TODO: remove
    def self.get_write_location(...)
      main.get_write_location(...)
    end

    def self.add_post_migrate_path_to_rails(force: false)
      return if ENV['SKIP_POST_DEPLOYMENT_MIGRATIONS'] && !force

      Rails.application.config.paths['db'].each do |db_path|
        path = Rails.root.join(db_path, 'post_migrate').to_s

        unless Rails.application.config.paths['db/migrate'].include? path
          Rails.application.config.paths['db/migrate'] << path

          # Rails memoizes migrations at certain points where it won't read the above
          # path just yet. As such we must also update the following list of paths.
          ActiveRecord::Migrator.migrations_paths << path
        end
      end
    end

    def self.dbname(ar_connection)
      if ar_connection.respond_to?(:pool) &&
          ar_connection.pool.respond_to?(:db_config) &&
          ar_connection.pool.db_config.respond_to?(:database)
        return ar_connection.pool.db_config.database
      end

      'unknown'
    end

    # TODO: remove
    def self.inside_transaction?
      main.inside_transaction?
    end

    # TODO: remove
    def self.set_open_transactions_baseline
      main.set_open_transactions_baseline
    end

    # TODO: remove
    def self.reset_open_transactions_baseline
      main.reset_open_transactions_baseline
    end

    # Monkeypatch rails with upgraded database observability
    def self.install_monkey_patches
      ActiveRecord::Base.prepend(ActiveRecordBaseTransactionMetrics)
    end

    # MonkeyPatch for ActiveRecord::Base for adding observability
    module ActiveRecordBaseTransactionMetrics
      extend ActiveSupport::Concern

      class_methods do
        # A monkeypatch over ActiveRecord::Base.transaction.
        # It provides observability into transactional methods.
        def transaction(**options, &block)
          ActiveSupport::Notifications.instrument('transaction.active_record', { connection: connection }) do
            super(**options, &block)
          end
        end
      end
    end
  end
end

Gitlab::Database.prepend_mod_with('Gitlab::Database')
