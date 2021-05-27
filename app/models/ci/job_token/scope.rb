# frozen_string_literal: true

# TODO: add comment

module Ci
  module JobToken
    class Scope
      def initialize(project)
        @project = project
      end

      def includes?(target_project)
        target_project == project ||
          Ci::JobToken::ScopeLink.from(project).to(target_project).exists?
      end

      def all_projects
        Project.from_union([
          Project.id_in(Ci::JobToken::ScopeLink.from(project).select(:target_id)),
          Project.id_in(project.id)
        ])
      end

      private

      attr_reader :project
    end
  end
end
