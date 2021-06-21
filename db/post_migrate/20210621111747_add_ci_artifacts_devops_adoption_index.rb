# frozen_string_literal: true
#
class AddCiArtifactsDevopsAdoptionIndex < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  NEW_INDEX = 'index_ci_job_artifacts_on_file_type_for_devops_adoption'
  INDEX_SAST = 'index_ci_job_artifacts_sast_for_devops_adoption'
  INDEX_DAST = 'index_ci_job_artifacts_dast_for_devops_adoption'

  def up
    add_concurrent_index :ci_job_artifacts, [:file_type, :project_id, :created_at], name: NEW_INDEX, where: 'file_type IN (5,6,8,23)'
    remove_concurrent_index_by_name :ci_job_artifacts, INDEX_SAST
    remove_concurrent_index_by_name :ci_job_artifacts, INDEX_DAST
  end

  def down
    add_concurrent_index :ci_job_artifacts, [:project_id, :created_at], where: "file_type = 5", name: INDEX_SAST
    add_concurrent_index :ci_job_artifacts, [:project_id, :created_at], where: "file_type = 8", name: INDEX_DAST
    remove_concurrent_index_by_name :ci_job_artifacts, NEW_INDEX
  end
end
