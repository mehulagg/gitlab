# frozen_string_literal: true

module Mutations
  module SecurityPolicy
    class CreateSecurityPolicyProject < BaseMutation
      include FindsProject

      graphql_name 'SecurityPolicyProjectCreate'

      authorize :security_orchestration_policies

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Full path of the project.'

      field :project, Types::ProjectType,
            null: true,
            description: 'Security Policy Project that was created.'

      def resolve(args)
        project = authorized_find!(args[:project_path])
        raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'Feature disabled' unless allowed?(project)

        result = create_policy(project, args[:policy_yaml])
        error_message = result[:status] == :error ? result[:message] : nil

        {
          project: error_message.nil? ? result[:policy_project] : nil,
          errors: [error_message].compact
        }
      end

      private

      def allowed?(project)
        Feature.enabled?(:security_orchestration_policies_configuration, project)
      end

      def create_policy(project, policy_yaml)
        ::Security::SecurityOrchestrationPolicies::ProjectCreateService
          .new(project: project, current_user: current_user, params: { policy_yaml: policy_yaml })
          .execute
      end
    end
  end
end
