# frozen_string_literal: true

module Constraints
  class RepositoryRedirectUrlConstrainer
    def matches?(request)
      path = request.params[:repository_path].delete_suffix('.git')
      query = request.query_string

      # Allow /info/refs, /info/refs?service=git-upload-pack, and
      # /info/refs?service=git-receive-pack, but nothing else.
      return false if query.present? && !query.match(/\Aservice=git-(upload|receive)-pack\z/)

      # Check if the path matches any known repository containers.
      # These also cover wikis, since a `.wiki` suffix is valid in project/group paths too.
      return true if NamespacePathValidator.valid_path?(path)
      return true if ProjectPathValidator.valid_path?(path)
      return true if path =~ Gitlab::PathRegex.full_snippets_repository_path_regex

      false
    end
  end
end
