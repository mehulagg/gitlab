# frozen_string_literal: true

class FinalizeCiBuildsBigintConversion < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  TABLE_NAME = 'ci_builds'
  PK_INDEX_NAME = 'index_ci_builds_on_converted_id'

  SECONDARY_INDEXES = [
    {
      original_name: :index_ci_builds_on_commit_id_artifacts_expired_at_and_id,
      temporary_name: :index_ci_builds_on_commit_id_expire_at_and_converted_id,
      columns: [:commit_id, :artifacts_expire_at, :id_convert_to_bigint],
      options: {
        where: "type::text = 'Ci::Build'::text
                AND (retried = false OR retried IS NULL)
                AND (name::text = ANY (ARRAY['sast'::character varying::text,
                                             'secret_detection'::character varying::text,
                                             'dependency_scanning'::character varying::text,
                                             'container_scanning'::character varying::text,
                                             'dast'::character varying::text]))"
      }
    },
    {
      original_name: :index_ci_builds_on_project_id_and_id,
      temporary_name: :index_ci_builds_on_project_and_converted_id,
      columns: [:project_id, :id_convert_to_bigint],
      options: {}
    },
    {
      original_name: :index_ci_builds_on_runner_id_and_id_desc,
      temporary_name: :index_ci_builds_on_runner_id_and_converted_id_desc,
      columns: [:runner_id, :id_convert_to_bigint],
      options: { order: { id_convert_to_bigint: :desc } }
    },
    {
      original_name: :index_for_resource_group,
      temporary_name: :index_ci_builds_on_resource_group_and_converted_id,
      columns: [:resource_group_id, :id_convert_to_bigint],
      options: { where: 'resource_group_id IS NOT NULL' }
    },
    {
      original_name: :index_security_ci_builds_on_name_and_id_parser_features,
      temporary_name: :index_security_ci_builds_on_name_and_converted_id_parser,
      columns: [:name, :id_convert_to_bigint],
      options: {
        where: "(name::text = ANY (ARRAY['container_scanning'::character varying::text,
                                         'dast'::character varying::text,
                                         'dependency_scanning'::character varying::text,
                                         'license_management'::character varying::text,
                                         'sast'::character varying::text,
                                         'secret_detection'::character varying::text,
                                         'coverage_fuzzing'::character varying::text,
                                         'license_scanning'::character varying::text])
                ) AND type::text = 'Ci::Build'::text",

      }
    }
  ].freeze

  MANUAL_INDEX_NAMES = {
    original_name: :index_ci_builds_runner_id_pending_covering,
    temporary_name: :index_ci_builds_runner_id_and_converted_id_pending_covering
  }.freeze

  REFERENCING_FOREIGN_KEYS = [
    [:terraform_state_versions, :ci_build_id, :nullify, 'fk_'],
    [:ci_unit_test_failures, :build_id, :cascade, 'fk_'],
    [:ci_build_trace_sections, :build_id, :cascade, 'fk_'],
    [:dast_site_profiles_builds, :ci_build_id, :cascade, 'fk_'],
    [:ci_sources_pipelines, :source_job_id, :cascade, 'fk_'],
    [:ci_test_case_failures, :build_id, :cascade, 'fk_'],
    [:ci_resources, :build_id, :nullify, 'fk_'],
    [:dast_scanner_profiles_builds, :ci_build_id, :cascade, 'fk_'],
    [:ci_build_pending_states, :build_id, :cascade, 'fk_rails_'],
    [:ci_build_trace_chunks, :build_id, :cascade, 'fk_rails_'],
    [:ci_build_report_results, :build_id, :cascade, 'fk_rails_'],
    [:ci_build_needs, :build_id, :cascade, 'fk_rails_'],
    [:security_scans, :build_id, :cascade, 'fk_rails_'],
    [:ci_builds_runner_session, :build_id, :cascade, 'fk_rails_'],
    [:ci_pending_builds, :build_id, :cascade, 'fk_rails_'],
    [:pages_deployments, :ci_build_id, :nullify, 'fk_rails_'],
    [:ci_job_artifacts, :job_id, :cascade, 'fk_rails_'],
    [:ci_running_builds, :build_id, :cascade, 'fk_rails_'],
    [:ci_builds_metadata, :build_id, :cascade, 'fk_rails_'],
    [:requirements_management_test_reports, :build_id, :nullify, 'fk_rails_'],
    [:ci_job_variables, :job_id, :cascade, 'fk_rails_']
  ].freeze

  def up
    ensure_batched_background_migration_is_finished(
      job_class_name: 'CopyColumnUsingBackgroundMigrationJob',
      table_name: TABLE_NAME,
      column_name: 'id',
      job_arguments: [['id'], ['id_convert_to_bigint']]
    )

    swap_columns
  end

  def down
    swap_columns
  end

  private

  def swap_columns
    # Create new indexes that include the id_convert_to_bigint column
    create_indexes
    # Create new FKs from other tables that will reference the id_convert_to_bigint column
    create_referencing_foreign_keys

    with_lock_retries(raise_on_exhaustion: true) do
      quoted_table_name = quote_table_name(TABLE_NAME)

      quoted_referencing_tables = REFERENCING_FOREIGN_KEYS.map { |rt| quote_table_name(rt.first) }.join(', ')
      execute "LOCK TABLE #{quoted_table_name}, #{quoted_referencing_tables} IN ACCESS EXCLUSIVE MODE"

      # Swap column names
      temporary_name = 'id_tmp'
      execute "ALTER TABLE #{quoted_table_name} RENAME COLUMN id TO #{quote_column_name(temporary_name)}"
      execute "ALTER TABLE #{quoted_table_name} RENAME COLUMN #{quote_column_name(:id_convert_to_bigint)} TO #{quote_column_name(:id)}"
      execute "ALTER TABLE #{quoted_table_name} RENAME COLUMN #{quote_column_name(temporary_name)} TO #{quote_column_name(:id_convert_to_bigint)}"

      function_name = Gitlab::Database::UnidirectionalCopyTrigger.on_table(TABLE_NAME)
        .name([:id, :stage_id], [:id_convert_to_bigint, :stage_id_convert_to_bigint])
      execute "ALTER FUNCTION #{quote_table_name(function_name)} RESET ALL"

      # Swap defaults
      execute "ALTER SEQUENCE ci_builds_id_seq OWNED BY #{TABLE_NAME}.id"
      change_column_default TABLE_NAME, :id, -> { "nextval('ci_builds_id_seq'::regclass)" }
      change_column_default TABLE_NAME, :id_convert_to_bigint, 0

      # Swap PK constraint
      execute "ALTER TABLE #{quoted_table_name} DROP CONSTRAINT ci_builds_pkey CASCADE"
      rename_index TABLE_NAME, PK_INDEX_NAME, 'ci_builds_pkey'
      execute "ALTER TABLE #{quoted_table_name} ADD CONSTRAINT ci_builds_pkey PRIMARY KEY USING INDEX ci_builds_pkey"

      # Remove old column indexes and change new column indexes to have the original names
      rename_secondary_indexes
      # Remove FKs referencing the old column and rename the FKs referencing the new column to their original names
      rename_referencing_foreign_keys
    end
  end

  def create_indexes
    add_concurrent_index TABLE_NAME, :id_convert_to_bigint, unique: true, name: PK_INDEX_NAME

    SECONDARY_INDEXES.each do |index_definition|
      options = index_definition[:options]
      options[:name] = index_definition[:temporary_name]

      add_concurrent_index(TABLE_NAME, index_definition[:columns], options)
    end

    unless index_name_exists?(TABLE_NAME, MANUAL_INDEX_NAMES[:temporary_name])
      execute(<<~SQL)
        CREATE INDEX CONCURRENTLY #{MANUAL_INDEX_NAMES[:temporary_name]}
        ON ci_builds (runner_id, id_convert_to_bigint) INCLUDE (project_id)
        WHERE status::text = 'pending'::text AND type::text = 'Ci::Build'::text
      SQL
    end
  end

  def rename_secondary_indexes
    (SECONDARY_INDEXES + [MANUAL_INDEX_NAMES]).each do |index_definition|
      remove_index(TABLE_NAME, name: index_definition[:original_name])
      rename_index(TABLE_NAME, index_definition[:temporary_name], index_definition[:original_name])
    end
  end

  def create_referencing_foreign_keys
    REFERENCING_FOREIGN_KEYS.each do |(from_table, column, on_delete, prefix)|
      temporary_name = "#{concurrent_foreign_key_name(from_table, column, prefix: prefix)}_tmp"

      add_concurrent_foreign_key(
        from_table,
        TABLE_NAME,
        column: column,
        target_column: :id_convert_to_bigint,
        name: temporary_name,
        on_delete: on_delete)
    end
  end

  def rename_referencing_foreign_keys
    REFERENCING_FOREIGN_KEYS.each do |(table, column, _, prefix)|
      existing_name = concurrent_foreign_key_name(table, column, prefix: prefix)
      temporary_name = "#{existing_name}_tmp"

      rename_constraint(table, temporary_name, existing_name)
    end
  end
end
