# frozen_string_literal: true

module Gitlab
  class ProjectCommitCount
    def self.commit_count_for(project, default_count: 0, max_count: nil)
      raw_repo = project.repository&.raw_repository
      return default_count unless raw_repo&.root_ref

      Gitlab::GitalyClient::CommitService.new(raw_repo).commit_count(raw_repo.root_ref, {
        all: true, # include all branches
        max_count: max_count # limit as an optimization
      })
    end
  end
end
