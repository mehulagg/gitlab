# frozen_string_literal: true

module Branches
  class DeleteService < BaseService
    def execute(branch_name)
      repository = project.repository
      merge_requests = project.merge_requests.opened.by_source_or_target_branch(branch_name)
      branch = repository.find_branch(branch_name)

      unless current_user.can?(:push_code, project)
        return ServiceResponse.error(
          message: 'You dont have push access to repo',
          http_status: 405)
      end

      unless branch
        return ServiceResponse.error(
          message: 'No such branch',
          http_status: 404)
      end

      if repository.rm_branch(current_user, branch_name)
        unlock_artifacts(branch_name)

        merge_requests.each do |merge_request|
          GitlabSchema.subscriptions.trigger('mergeRequestUpdated', { project_path: merge_request.project.full_path, iid: merge_request.iid }, merge_request)
        end

        ServiceResponse.success(message: 'Branch was deleted')
      else
        ServiceResponse.error(
          message: 'Failed to remove branch',
          http_status: 400)
      end
    rescue Gitlab::Git::PreReceiveError, Gitlab::Git::CommandError => ex
      ServiceResponse.error(message: ex.message, http_status: 400)
    end

    private

    def unlock_artifacts(branch_name)
      Ci::RefDeleteUnlockArtifactsWorker.perform_async(project.id, current_user.id, "#{::Gitlab::Git::BRANCH_REF_PREFIX}#{branch_name}")
    end
  end
end
