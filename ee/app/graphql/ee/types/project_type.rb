# frozen_string_literal: true

module EE
  module Types
    module ProjectType
      extend ActiveSupport::Concern

      prepended do
        field :security_scanners, ::Types::SecurityScanners, null: true,
          description: 'Information about security analyzers used in the project'

        field :dast_scanner_profiles,
            ::Types::DastScannerProfileType.connection_type,
            null: true,
            description: 'The DAST scanner profiles associated with the project'

        field :sast_ci_configuration, ::Types::CiConfiguration::Sast::Type, null: true,
          calls_gitaly: true,
          description: 'SAST CI configuration for the project'

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
              extras: [:lookahead],
              resolver: ::Resolvers::RequirementsManagement::RequirementsResolver

        field :requirement_states_count, ::Types::RequirementsManagement::RequirementStatesCountType, null: true,
              description: 'Number of requirements for the project by their state'

        field :compliance_frameworks, ::Types::ComplianceManagement::ComplianceFrameworkType.connection_type,
              description: 'Compliance frameworks associated with the project',
              resolver: ::Resolvers::ComplianceFrameworksResolver,
              null: true

        field :security_dashboard_path, GraphQL::STRING_TYPE,
              description: "Path to project's security dashboard",
              null: true

        field :iterations, ::Types::IterationType.connection_type, null: true,
              description: 'Find iterations',
              resolver: ::Resolvers::IterationsResolver

        field :dast_site_profile,
              ::Types::DastSiteProfileType,
              null: true,
              resolver: ::Resolvers::DastSiteProfileResolver.single,
              description: 'DAST Site Profile associated with the project'

        field :dast_site_profiles,
              ::Types::DastSiteProfileType.connection_type,
              null: true,
              description: 'DAST Site Profiles associated with the project',
              resolver: ::Resolvers::DastSiteProfileResolver

        field :dast_site_validation,
              ::Types::DastSiteValidationType,
              null: true,
              resolver: ::Resolvers::DastSiteValidationResolver.single,
              description: 'DAST Site Validation associated with the project'

        field :dast_site_validations,
              ::Types::DastSiteValidationType.connection_type,
              null: true,
              resolver: ::Resolvers::DastSiteValidationResolver,
              description: 'DAST Site Validations associated with the project'

        field :cluster_agent,
              ::Types::Clusters::AgentType,
              null: true,
              description: 'Find a single cluster agent by name',
              resolver: ::Resolvers::Clusters::AgentsResolver.single

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

        field :actual_repository_size_limit,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Size limit for the repository in bytes'

        field :code_coverage_summary,
              ::Types::Ci::CodeCoverageSummaryType,
              null: true,
              description: 'Code coverage summary associated with the project',
              resolver: ::Resolvers::Ci::CodeCoverageSummaryResolver

        field :incident_management_oncall_schedules,
              ::Types::IncidentManagement::OncallScheduleType.connection_type,
              null: true,
              description: 'Incident Management On-call schedules of the project',
              resolver: ::Resolvers::IncidentManagement::OncallScheduleResolver

        def actual_repository_size_limit
          object.actual_size_limit
        end

        def dast_scanner_profiles
          DastScannerProfilesFinder.new(project_ids: [object.id]).execute
        end

        def requirement_states_count
          return unless Ability.allowed?(current_user, :read_requirement, object)

          Hash.new(0).merge(object.requirements.counts_by_state)
        end

        def sast_ci_configuration
          return unless Ability.allowed?(current_user, :download_code, object)

          ::Security::CiConfiguration::SastParserService.new(object).configuration
        end

        def security_dashboard_path
          Rails.application.routes.url_helpers.project_security_dashboard_index_path(object)
        end

        def security_scanners
          object
        end
      end
    end
  end
end
