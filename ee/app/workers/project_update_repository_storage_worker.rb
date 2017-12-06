class ProjectUpdateRepositoryStorageWorker
  include ApplicationWorker

  def perform(project_id, new_repository_storage_key)
    project = Project.find(project_id)

    ::Projects::UpdateRepositoryStorageService.new(project).execute(new_repository_storage_key)
  end
end
