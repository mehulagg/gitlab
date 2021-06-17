# frozen_string_literal: true

class UpdateIndexForRunningContainerScanningWithCommitIdAndArtifactsExpireAt < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  CI_BUILDS_ON_COMMIT_ID_OLD_INDEX_NAME = 'index_ci_builds_on_commit_id_artifacts_expired_at_and_id'
  CI_BUILDS_ON_COMMIT_ID_NEW_INDEX_NAME = 'index_ci_builds_on_commit_id_secure_artifacts_expired_at_and_id'
  CI_BUILDS_ON_COMMIT_ID_OLD_CLAUSE = "((name)::text = ANY (ARRAY[('sast'::character varying)::text,
                                       ('secret_detection'::character varying)::text,
                                       ('dependency_scanning'::character varying)::text,
                                       ('container_scanning'::character varying)::text,
                                       ('dast'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text) AND ((retried = false) OR (retried IS NULL))"
  CI_BUILDS_ON_COMMIT_ID_NEW_CLAUSE = "((name)::text = ANY (ARRAY[('sast'::character varying)::text,
                                       ('secret_detection'::character varying)::text,
                                       ('dependency_scanning'::character varying)::text,
                                       ('container_scanning'::character varying)::text,
                                       ('dast'::character varying)::text,
                                       ('running_container_scanning'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text) AND ((retried = false) OR (retried IS NULL))"

  def up
    add_concurrent_index :ci_builds, [:commit_id, :artifacts_expire_at, :id], name: CI_BUILDS_ON_COMMIT_ID_NEW_INDEX_NAME, where: CI_BUILDS_ON_COMMIT_ID_NEW_CLAUSE
    remove_concurrent_index_by_name :ci_builds, CI_BUILDS_ON_COMMIT_ID_OLD_INDEX_NAME
  end

  def down
    add_concurrent_index :ci_builds, [:commit_id, :artifacts_expire_at, :id], name: CI_BUILDS_ON_COMMIT_ID_OLD_INDEX_NAME, where: CI_BUILDS_ON_COMMIT_ID_OLD_CLAUSE
    remove_concurrent_index_by_name :ci_builds, CI_BUILDS_ON_COMMIT_ID_NEW_INDEX_NAME
  end
end
