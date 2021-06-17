# frozen_string_literal: true

class UpdateIndexForRunningContainerScanningWithUserIdAndNameReportType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  SECURE_CI_BUILDS_ON_USER_ID_OLD_INDEX_NAME = 'index_secure_ci_builds_on_user_id_name_created_at'
  SECURE_CI_BUILDS_ON_USER_ID_NEW_INDEX_NAME = 'index_ci_builds_on_user_id_name_created_at_secure_features'
  SECURE_CI_BUILDS_ON_USER_ID_OLD_CLAUSE = "((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text,
                                            ('dast'::character varying)::text,
                                            ('dependency_scanning'::character varying)::text,
                                            ('license_management'::character varying)::text,
                                            ('license_scanning'::character varying)::text,
                                            ('sast'::character varying)::text,
                                            ('coverage_fuzzing'::character varying)::text,
                                            ('apifuzzer_fuzz'::character varying)::text,
                                            ('apifuzzer_fuzz_dnd'::character varying)::text,
                                            ('secret_detection'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text)"
  SECURE_CI_BUILDS_ON_USER_ID_NEW_CLAUSE = "((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text,
                                            ('dast'::character varying)::text,
                                            ('dependency_scanning'::character varying)::text,
                                            ('license_management'::character varying)::text,
                                            ('license_scanning'::character varying)::text,
                                            ('sast'::character varying)::text,
                                            ('coverage_fuzzing'::character varying)::text,
                                            ('apifuzzer_fuzz'::character varying)::text,
                                            ('apifuzzer_fuzz_dnd'::character varying)::text,
                                            ('running_container_scanning'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text)"

  def up
    add_concurrent_index :ci_builds, [:user_id, :name, :created_at], name: SECURE_CI_BUILDS_ON_USER_ID_NEW_INDEX_NAME, where: SECURE_CI_BUILDS_ON_USER_ID_NEW_CLAUSE
    remove_concurrent_index_by_name :ci_builds, SECURE_CI_BUILDS_ON_USER_ID_OLD_INDEX_NAME
  end

  def down
    add_concurrent_index :ci_builds, [:user_id, :name, :created_at], name: SECURE_CI_BUILDS_ON_USER_ID_OLD_INDEX_NAME, where: SECURE_CI_BUILDS_ON_USER_ID_OLD_CLAUSE
    remove_concurrent_index_by_name :ci_builds, SECURE_CI_BUILDS_ON_USER_ID_NEW_INDEX_NAME
  end
end
