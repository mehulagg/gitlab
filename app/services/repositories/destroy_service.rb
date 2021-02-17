# frozen_string_literal: true

class Repositories::DestroyService < Repositories::BaseService
  def execute
    return success unless repository

    # Flush the cache for both repositories. This has to be done _before_
    # removing the physical repositories as some expiration code depends on
    # Git data (e.g. a list of branch names).
    ignore_git_errors { repository.before_delete }

    # Because GitlabShellWorker is inside a run_after_commit callback it will
    # never be triggered on a read-only instance.
    #
    # Issue: https://gitlab.com/gitlab-org/gitlab/-/issues/223272
    if Gitlab::Database.read_only?
      Repositories::ShellDestroyService.new(repository).execute
    else
      container.run_after_commit do
        Repositories::ShellDestroyService.new(repository).execute
      end
    end

    success
  end
end
