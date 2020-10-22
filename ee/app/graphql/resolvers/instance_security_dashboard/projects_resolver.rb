# frozen_string_literal: true

module Resolvers
  module InstanceSecurityDashboard
    class ProjectsResolver < BaseResolver
      type ::Types::ProjectType, null: true

      alias_method :dashboard, :object

      def resolve(**args)
        dashboard&.projects
      end
    end
  end
end
