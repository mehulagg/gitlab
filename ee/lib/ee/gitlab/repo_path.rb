# frozen_string_literal: true

module EE
  module Gitlab
    module RepoPath
      module ClassMethods
        def find_project(project_path)
          return super unless License.feature_available?(:project_aliases)

          if project_alias = ProjectAlias.find_by_name(project_path)
            project_alias.project
          else
            super
          end
        end
      end
    end
  end
end
