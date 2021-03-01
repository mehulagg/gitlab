# frozen_string_literal: true

module EE
  module Resolvers
    module NamespaceProjectsResolver
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        argument :has_code_coverage, GraphQL::BOOLEAN_TYPE,
             required: false,
             default_value: false,
             description: 'Returns only the projects which have code coverage.'

        argument :has_vulnerabilities, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 default_value: false,
                 description: 'Returns only the projects which have vulnerabilities.'
      end

      private

      override :params
      def params(args)
        {
          include_subgroups: args.dig(:include_subgroups),
          sort: args.dig(:sort),
          search: args.dig(:search),
          ids: parse_gids(args.dig(:ids)),
          has_vulnerabilities: args.dig(:has_vulnerabilities),
          has_code_coverage: args.dig(:has_code_coverage)
        }
      end
    end
  end
end
