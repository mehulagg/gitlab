# frozen_string_literal: true

class Repositories::ShellDestroyService < Repositories::BaseService
  def execute
    return success unless repository

    GitlabShellWorker.perform_async(:remove_repository, repository.shard, removal_path)
  end
end
