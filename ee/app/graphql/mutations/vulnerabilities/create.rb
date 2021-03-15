# frozen_string_literal: true

module Mutations
  module Vulnerabilities
    class Create < BaseMutation
      graphql_name 'VulnerabilityCreate'

      authorize :admin_vulnerability

      field :vulnerability, Types::VulnerabilityType,
        null: false,
        description: 'The vulnerability created.'

      argument :project, ::Types::GlobalIDType[::Project],
        required: true,
        description: 'ID of the project to attach the Vulnerability to.'

      argument :title, GraphQL::STRING_TYPE,
        required: true,
        description: 'Title of the vulnerability.'

      argument :description, GraphQL::STRING_TYPE,
        required: true,
        description: 'Description of the vulnerability.'

      argument :scanner_type, Types::SecurityScannerTypeEnum,
        required: true,
        description: 'Type of the security scanner used to discover the vulnerability.'

      argument :scanner_name, GraphQL::STRING_TYPE,
        required: true,
        description: 'Name of the security scanner used to discover the vulnerability.'

      argument :identifiers, [Types::VulnerabilityIdentifierType],
        required: true,
        description: 'List of CVE or CWE identifiers for the vulnerability.'

      argument :severity, Types::VulnerabilitySeverityEnum,
        required: false,
        description: 'Severity of the vulnerability (defaults to `unknown`).',
        default_value: 'unknown'

      argument :state, Types::VulnerabilityStateEnum,
        required: false,
        description: 'State of the vulnerability (detaults to `detected`).',
        default_value: 'detected'

      argument :solution, GraphQL::STRING_TYPE,
        required: false,
        description: 'How to fix this vulnerability.'

      argument :message, GraphQL::STRING_TYPE,
        required: false,
        description: '???.'

      argument :detected_at, Types::TimeType,
        required: false,
        description: 'Timestamp of when the vulnerability was first detected (defaults to creation time).'

      argument :confirmed_at, Types::TimeType,
        required: false,
        description: 'Timestamp of when the vulnerability state was changed to confirmed (defaults to creation time if status is not `detected`).'

      argument :resolved_at, Types::TimeType,
        required: false,
        description: 'Timestamp of when the vulnerability state was changed to resolved (defaults to creation time if status is not `detected`).'
    end

    def resolve(**attributes)
    end
  end
end
