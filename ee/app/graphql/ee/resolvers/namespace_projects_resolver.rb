# frozen_string_literal: true

module EE
  module Resolvers
    module NamespaceProjectsResolver
      extend ActiveSupport::Concern

      prepended do
        argument :has_vulnerabilities, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 default_value: false,
                 description: 'Returns only the projects which have vulnerabilities.'
      end

      def resolve(include_subgroups:, search:, sort:, has_vulnerabilities: false)
        projects = super(include_subgroups: include_subgroups, search: search, sort: sort)
        projects = projects.has_vulnerabilities if has_vulnerabilities
        projects = projects.order_by_total_repository_size_excess_desc(namespace.actual_size_limit) if sort == :storage
        projects
      end
    end
  end
end
