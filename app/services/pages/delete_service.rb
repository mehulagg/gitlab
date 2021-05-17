# frozen_string_literal: true

module Pages
  class DeleteService < BaseService
    def execute
      project.mark_pages_as_not_deployed

      # project.pages_domains.delete_all will just nullify project_id:
      # https://apidock.com/rails/ActiveRecord/Relation/delete_all,
      # > Be careful with relations though, in particular :dependent rules defined on associations are not honored.
      PagesDomain.for_project(project).delete_all

      DestroyPagesDeploymentsWorker.perform_async(project.id)

      # TODO: remove this call https://gitlab.com/gitlab-org/gitlab/-/issues/320775
      PagesRemoveWorker.perform_async(project.id) if ::Settings.pages.local_store.enabled
    end
  end
end
