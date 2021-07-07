# frozen_string_literal: true

module Gitlab
  module GithubImport
    class ImportIssueWorker # rubocop:disable Scalability/IdempotentWorker
      include ObjectImporter
    end
  end
end
