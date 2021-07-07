# frozen_string_literal: true

module Gitlab
  module GithubImport
    class ImportPullRequestMergedByWorker # rubocop:disable Scalability/IdempotentWorker
      include ObjectImporter

      tags :exclude_from_kubernetes
    end
  end
end
