# frozen_string_literal: true

module Gitlab
  module GithubImport
    class ImportLfsObjectWorker # rubocop:disable Scalability/IdempotentWorker
      include ObjectImporter
    end
  end
end
