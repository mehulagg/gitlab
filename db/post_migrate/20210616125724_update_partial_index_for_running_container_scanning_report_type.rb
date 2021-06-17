# frozen_string_literal: true

class UpdatePartialIndexForRunningContainerScanningReportType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  PARTIAL_CI_BUILDS_ON_USER_ID_OLD_INDEX_NAME = 'index_partial_ci_builds_on_user_id_name_parser_features'
  PARTIAL_CI_BUILDS_ON_USER_ID_NEW_INDEX_NAME = 'index_partial_ci_builds_on_user_id_name_secure_parser_features'
  PARTIAL_CI_BUILDS_ON_USER_ID_OLD_CLAUSE = "((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text,
                                             ('dast'::character varying)::text,
                                             ('dependency_scanning'::character varying)::text,
                                             ('license_management'::character varying)::text,
                                             ('license_scanning'::character varying)::text,
                                             ('sast'::character varying)::text,
                                             ('coverage_fuzzing'::character varying)::text,
                                             ('secret_detection'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text)"
  PARTIAL_CI_BUILDS_ON_USER_ID_NEW_CLAUSE = "((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text,
                                             ('dast'::character varying)::text,
                                             ('dependency_scanning'::character varying)::text,
                                             ('license_management'::character varying)::text,
                                             ('license_scanning'::character varying)::text,
                                             ('sast'::character varying)::text,
                                             ('coverage_fuzzing'::character varying)::text,
                                             ('secret_detection'::character varying)::text,
                                             ('running_container_scanning'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text)"

  def up
    add_concurrent_index :ci_builds, [:user_id, :name], name: PARTIAL_CI_BUILDS_ON_USER_ID_NEW_INDEX_NAME, where: PARTIAL_CI_BUILDS_ON_USER_ID_NEW_CLAUSE
    remove_concurrent_index_by_name :ci_builds, PARTIAL_CI_BUILDS_ON_USER_ID_OLD_INDEX_NAME
  end

  def down
    add_concurrent_index :ci_builds, [:user_id, :name], name: PARTIAL_CI_BUILDS_ON_USER_ID_OLD_INDEX_NAME, where: PARTIAL_CI_BUILDS_ON_USER_ID_OLD_CLAUSE
    remove_concurrent_index_by_name :ci_builds, PARTIAL_CI_BUILDS_ON_USER_ID_NEW_INDEX_NAME
  end
end
