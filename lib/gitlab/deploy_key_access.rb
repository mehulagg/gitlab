# frozen_string_literal: true

module Gitlab
  class DeployKeyAccess < UserAccess
    extend Gitlab::Cache::RequestCache

    request_cache_key do
      [user&.id, deploy_key&.id, project&.id]
    end

    attr_reader :deploy_key

    def initialize(deploy_key, project: nil)
      @deploy_key = deploy_key
      @user = deploy_key&.user
      @project = project
    end

    request_cache def can_push_to_branch?(ref)
      return true unless protected?(ProtectedBranch, project, ref)

      protected_branch_accessible_to?(ref, action: :push)
    end

    private

    def protected_branch_accessible_to?(ref, action:)
      ProtectedBranch.protected_ref_accessible_to?(
        ref, deploy_key,
        project: project,
        action: action,
        protected_refs: project.protected_branches)
    end

    request_cache def can_access_git?
      true
    end
  end
end
