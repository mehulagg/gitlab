# frozen_string_literal: true

module Gitlab
  class GlRepository
    include Singleton

    PROJECT = RepoType.new(
      name: :project,
      access_checker_class: Gitlab::GitAccess,
      repository_accessor: -> (project) { project.repository }
    ).freeze
    WIKI = RepoType.new(
      name: :wiki,
      access_checker_class: Gitlab::GitAccessWiki,
      repository_accessor: -> (project) { project.wiki.repository }
    ).freeze
    PERSONAL_SNIPPET = RepoType.new(
      name: :personal_snippet,
      access_checker_class: Gitlab::GitAccessSnippet,
      repository_accessor: -> (snippet) { snippet.repository },
      collection: true,
      prefix: :snippet
    ).freeze
    PROJECT_SNIPPET = RepoType.new(
      name: :project_snippet,
      access_checker_class: Gitlab::GitAccessSnippet,
      repository_accessor: -> (snippet) { snippet.repository },
      collection: true,
      prefix: :snippet
    ).freeze

    TYPES = {
      PROJECT.name.to_s => PROJECT,
      WIKI.name.to_s => WIKI,
      PERSONAL_SNIPPET.name.to_s => PERSONAL_SNIPPET,
      PROJECT_SNIPPET.name.to_s => PROJECT_SNIPPET
    }.freeze

    def self.types
      instance.types
    end

    def self.parse(gl_repository)
      type_name, _id = gl_repository.split('-').first
      type = types[type_name]
      subject_id = type&.fetch_id(gl_repository)

      unless subject_id
        raise ArgumentError, "Invalid GL Repository \"#{gl_repository}\""
      end

      object =
        if type == PERSONAL_SNIPPET || type == PROJECT_SNIPPET
          Snippet.find_by_id(subject_id)
        else
          Project.find_by_id(subject_id)
        end

      [object, type]
    end

    def self.default_type
      PROJECT
    end

    def types
      TYPES
    end

    private_class_method :instance
  end
end

Gitlab::GlRepository.prepend_if_ee('::EE::Gitlab::GlRepository')
