# frozen_string_literal: true

module Constraints
  class RepositoryRedirectUrlConstrainer
    def matches?(request)
      path = request.params[:repository_path]
      query = request.query_string

      return false if query.present? && !query.match(/\Aservice=git-(upload|receive)-pack\z/)
      return true if NamespacePathValidator.valid_path?(path)
      return true if ProjectPathValidator.valid_path?(path)
      return true if path =~ Gitlab::PathRegex.full_snippets_repository_path_regex

      false
    end
  end
end
