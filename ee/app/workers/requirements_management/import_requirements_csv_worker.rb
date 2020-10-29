# frozen_string_literal: true

class ImportRequirementsCsvWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :requirements_management
  worker_resource_boundary :cpu
  weight 2

  sidekiq_retries_exhausted do |job|
    Upload.find(job['args'][2]).destroy
  end

  def perform(current_user_id, project_id, upload_id)
    @user = User.find(current_user_id)
    @project = Project.find(project_id)
    @upload = Upload.find(upload_id)

    importer = RequirementsManagement::ImportCsvService.new(@user, @project, @upload.retrieve_uploader)
    importer.execute

    @upload.destroy
  end
end
