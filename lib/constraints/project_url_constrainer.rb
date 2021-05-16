# frozen_string_literal: true

module Constraints
  class ProjectUrlConstrainer
    def matches?(request, existence_check: true)
      namespace_path = request.params[:namespace_id]
      project_path = request.params[:project_id] || request.params[:id]
      full_path = [namespace_path, project_path].join('/')

      return false unless ProjectPathValidator.valid_path?(full_path)
      return true unless existence_check

      # We intentionally allow SELECT(*) here so result of this query can be used
      # as cache for further Project.find_by_full_path calls within request
      project = Project.find_by_full_path(full_path, follow_redirects: request.get?)

      if project.present?
        Gitlab::Sharding::Current.set_top_level_namespace!(project.root_ancestor)

        true
      else
        false
      end
    end
  end
end
