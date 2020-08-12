# frozen_string_literal: true

module EE
  module Types
    module ProjectType
      extend ActiveSupport::Concern

      prepended do
        field :security_scanners, ::Types::SecurityScanners, null: true,
          description: 'Information about security analyzers used in the project',
          resolve: -> (project, _args, ctx) do
            project
          end

        field :dast_scanner_profiles,
            ::Types::DastScannerProfileType.connection_type,
            null: true,
            description: 'The DAST scanner profiles associated with the project',
            resolve: -> (project, _args, _ctx) do
              return DastScannerProfile.none unless ::Feature.enabled?(:security_on_demand_scans_feature_flag, project)

              project.dast_scanner_profiles
            end

        field :vulnerabilities,
              ::Types::VulnerabilityType.connection_type,
              null: true,
              description: 'Vulnerabilities reported on the project',
              resolver: ::Resolvers::VulnerabilitiesResolver

        field :vulnerability_scanners,
              ::Types::VulnerabilityScannerType.connection_type,
              null: true,
              description: 'Vulnerability scanners reported on the project vulnerabilties',
              resolver: ::Resolvers::Vulnerabilities::ScannersResolver

        field :vulnerability_severities_count, ::Types::VulnerabilitySeveritiesCountType, null: true,
               description: 'Counts for each severity of vulnerability of the project',
               resolve: -> (obj, *) { obj.vulnerability_statistic || Hash.new(0) }

        field :requirement, ::Types::RequirementsManagement::RequirementType, null: true,
              description: 'Find a single requirement. Available only when feature flag `requirements_management` is enabled.',
              resolver: ::Resolvers::RequirementsManagement::RequirementsResolver.single

        field :requirements, ::Types::RequirementsManagement::RequirementType.connection_type, null: true,
              description: 'Find requirements. Available only when feature flag `requirements_management` is enabled.',
              resolver: ::Resolvers::RequirementsManagement::RequirementsResolver

        field :requirement_states_count, ::Types::RequirementsManagement::RequirementStatesCountType, null: true,
              description: 'Number of requirements for the project by their state',
              resolve: -> (project, args, ctx) do
                return unless requirements_available?(project, ctx[:current_user])

                Hash.new(0).merge(project.requirements.counts_by_state)
              end

        field :compliance_frameworks, ::Types::ComplianceManagement::ComplianceFrameworkType.connection_type,
              description: 'Compliance frameworks associated with the project',
              resolver: ::Resolvers::ComplianceFrameworksResolver,
              null: true

        field :security_dashboard_path, GraphQL::STRING_TYPE,
          description: "Path to project's security dashboard",
          null: true,
          resolve: -> (project, args, ctx) do
            Rails.application.routes.url_helpers.project_security_dashboard_index_path(project)
          end

        field :iterations, ::Types::IterationType.connection_type, null: true,
              description: 'Find iterations',
              resolver: ::Resolvers::IterationsResolver

        field :dast_site_profiles,
              ::Types::DastSiteProfileType.connection_type,
              null: true,
              description: 'DAST Site Profiles associated with the project',
              resolve: -> (obj, _args, _ctx) { obj.dast_site_profiles.with_dast_site }

        def self.requirements_available?(project, user)
          ::Feature.enabled?(:requirements_management, project, default_enabled: true) && Ability.allowed?(user, :read_requirement, project)
        end
      end
    end
  end
end
