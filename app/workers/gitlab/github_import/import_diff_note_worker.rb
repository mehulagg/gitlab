# frozen_string_literal: true

module Gitlab
  module GithubImport
    class ImportDiffNoteWorker # rubocop:disable Scalability/IdempotentWorker
      include ObjectImporter
    end
  end
end
