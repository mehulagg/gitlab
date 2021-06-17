# frozen_string_literal: true

class UpdateIndexForRunningContainerScanningWithNameAndIdReportType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  SECURITY_CI_BUILDS_ON_NAME_AND_ID_OLD_INDEX_NAME = 'index_security_ci_builds_on_name_and_id_parser_features'
  SECURITY_CI_BUILDS_ON_NAME_AND_ID_NEW_INDEX_NAME = 'index_ci_builds_on_name_and_id_secure_parser_features'
  SECURITY_CI_BUILDS_ON_NAME_AND_ID_OLD_CLAUSE = "((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text,
                                                  ('dast'::character varying)::text,
                                                  ('dependency_scanning'::character varying)::text,
                                                  ('license_management'::character varying)::text,
                                                  ('sast'::character varying)::text,
                                                  ('secret_detection'::character varying)::text,
                                                  ('coverage_fuzzing'::character varying)::text,
                                                  ('license_scanning'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text)"
  SECURITY_CI_BUILDS_ON_NAME_AND_ID_NEW_CLAUSE = "((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text,
                                                  ('dast'::character varying)::text,
                                                  ('dependency_scanning'::character varying)::text,
                                                  ('license_management'::character varying)::text,
                                                  ('sast'::character varying)::text,
                                                  ('secret_detection'::character varying)::text,
                                                  ('coverage_fuzzing'::character varying)::text,
                                                  ('license_scanning'::character varying)::text,
                                                  ('running_container_scanning'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text)"

  def up
    add_concurrent_index :ci_builds, [:name, :id], name: SECURITY_CI_BUILDS_ON_NAME_AND_ID_NEW_INDEX_NAME, where: SECURITY_CI_BUILDS_ON_NAME_AND_ID_NEW_CLAUSE
    remove_concurrent_index_by_name :ci_builds, SECURITY_CI_BUILDS_ON_NAME_AND_ID_OLD_INDEX_NAME
  end

  def down
    add_concurrent_index :ci_builds, [:name, :id], name: SECURITY_CI_BUILDS_ON_NAME_AND_ID_OLD_INDEX_NAME, where: SECURITY_CI_BUILDS_ON_NAME_AND_ID_OLD_CLAUSE
    remove_concurrent_index_by_name :ci_builds, SECURITY_CI_BUILDS_ON_NAME_AND_ID_NEW_INDEX_NAME
  end
end
