# frozen_string_literal: true

module EE
  module Resolvers
    module NamespaceProjectsResolver
      extend ActiveSupport::Concern

      prepended do
        argument :has_vulnerabilities, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 default_value: false,
                 description: 'Returns only the projects which have vulnerabilities'
      end

      def resolve(include_subgroups:, search:, sort:, has_vulnerabilities: false)
        projects = super(include_subgroups: include_subgroups, search: search, sort: sort)

        has_vulnerabilities ? projects.has_vulnerabilities : projects
      end
    end
  end
end
