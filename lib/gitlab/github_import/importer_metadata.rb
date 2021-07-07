# frozen_string_literal: true

module Gitlab
  module GithubImport
    ImporterMetadata = Struct.new(
      :object_type,
      :importer_class,
      :sidekiq_worker_class,
      :representation_class,
      keyword_init: true
    )
  end
end
