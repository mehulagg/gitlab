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
              return DastScannerProfile.none unless ::Feature.enabled?(:security_on_demand_scans_feature_flag, project, default_enabled: true)

              DastScannerProfilesFinder.new(project_ids: [project.id]).execute
            end

        field :sast_ci_configuration, ::Types::CiConfiguration::Sast::Type, null: true,
          calls_gitaly: true,
          description: 'SAST CI configuration for the project',
          resolve: -> (project, args, ctx) do
            sast_ci_configuration(project)
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

        field :vulnerabilities_count_by_day,
              ::Types::VulnerabilitiesCountByDayType.connection_type,
              null: true,
              description: 'Number of vulnerabilities per day for the project',
              resolver: ::Resolvers::VulnerabilitiesCountPerDayResolver

        field :vulnerability_severities_count, ::Types::VulnerabilitySeveritiesCountType, null: true,
               description: 'Counts for each vulnerability severity in the project',
               resolver: ::Resolvers::VulnerabilitySeveritiesCountResolver

        field :requirement, ::Types::RequirementsManagement::RequirementType, null: true,
              description: 'Find a single requirement',
              resolver: ::Resolvers::RequirementsManagement::RequirementsResolver.single

        field :requirements, ::Types::RequirementsManagement::RequirementType.connection_type, null: true,
              description: 'Find requirements',
              resolver: ::Resolvers::RequirementsManagement::RequirementsResolver

        field :requirement_states_count, ::Types::RequirementsManagement::RequirementStatesCountType, null: true,
              description: 'Number of requirements for the project by their state',
              resolve: -> (project, args, ctx) do
                return unless Ability.allowed?(ctx[:current_user], :read_requirement, project)

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

        field :dast_site_profile,
              ::Types::DastSiteProfileType,
              null: true,
              resolve: -> (obj, args, _ctx) do
                # TODO: remove this coercion when the compatibility layer is removed
                # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
                gid = ::Types::GlobalIDType[::DastSiteProfile].coerce_isolated_input(args[:id])
                DastSiteProfilesFinder.new(project_id: obj.id, id: gid.model_id).execute.first
              end,
              description: 'DAST Site Profile associated with the project' do
                argument :id, ::Types::GlobalIDType[::DastSiteProfile], required: true, description: 'ID of the site profile'
              end

        field :dast_site_profiles,
              ::Types::DastSiteProfileType.connection_type,
              null: true,
              description: 'DAST Site Profiles associated with the project',
              resolve: -> (obj, _args, _ctx) { obj.dast_site_profiles.with_dast_site }

        field :cluster_agent,
              ::Types::Clusters::AgentType,
              null: true,
              description: 'Find a single cluster agent by name',
              resolver: ::Resolvers::Clusters::AgentResolver.single

        field :cluster_agents,
              ::Types::Clusters::AgentType.connection_type,
              extras: [:lookahead],
              null: true,
              description: 'Cluster agents associated with the project',
              resolver: ::Resolvers::Clusters::AgentsResolver

        field :repository_size_excess,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Size of repository that exceeds the limit in bytes'

        def self.requirements_available?(project, user)
          ::Feature.enabled?(:requirements_management, project, default_enabled: true) && Ability.allowed?(user, :read_requirement, project)
        end

        def self.sast_ci_configuration(project)
          ::Security::CiConfiguration::SastParserService.new(project).configuration
        end
      end
    end
  end
end
