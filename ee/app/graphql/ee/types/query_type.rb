# frozen_string_literal: true

module EE
  module Types
    module QueryType
      extend ActiveSupport::Concern

      prepended do
        field :iteration, ::Types::IterationType,
              null: true,
              resolve: -> (_obj, args, _ctx) { ::GitlabSchema.find_by_gid(args[:id]) },
              description: 'Find an iteration' do
          argument :id, ::Types::GlobalIDType[::Iteration],
                   required: true,
                   description: 'Find an iteration by its ID'
        end

        field :vulnerabilities,
              ::Types::VulnerabilityType.connection_type,
              null: true,
              description: "Vulnerabilities reported on projects on the current user's instance security dashboard",
              resolver: ::Resolvers::VulnerabilitiesResolver

        field :vulnerability,
              ::Types::VulnerabilityType,
              null: true,
              description: "Find a vulnerability",
              resolve: -> (_obj, args, _ctx) { ::GitlabSchema.find_by_gid(args[:id]) } do
          argument :id, ::Types::GlobalIDType[::Vulnerability],
                   required: true,
                   description: 'The Global ID of the Vulnerability'
        end

        field :vulnerabilities_count_by_day,
              ::Types::VulnerabilitiesCountByDayType.connection_type,
              null: true,
              description: "Number of vulnerabilities per day for the projects on the current user's instance security dashboard",
              resolver: ::Resolvers::VulnerabilitiesCountPerDayResolver

        field :vulnerabilities_count_by_day_and_severity,
              ::Types::VulnerabilitiesCountByDayAndSeverityType.connection_type,
              null: true,
              description: "Number of vulnerabilities per severity level, per day, for the projects on the current user's instance security dashboard",
              resolver: ::Resolvers::VulnerabilitiesHistoryResolver,
              deprecated: { reason: 'Use `vulnerabilitiesCountByDay`', milestone: '13.3' }

        field :geo_node, ::Types::Geo::GeoNodeType,
              null: true,
              resolver: ::Resolvers::Geo::GeoNodeResolver,
              description: 'Find a Geo node'

        field :instance_security_dashboard, ::Types::InstanceSecurityDashboardType,
              null: true,
              resolver: ::Resolvers::InstanceSecurityDashboardResolver,
              description: 'Fields related to Instance Security Dashboard'
      end
    end
  end
end
