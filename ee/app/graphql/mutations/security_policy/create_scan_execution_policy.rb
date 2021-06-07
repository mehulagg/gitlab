# frozen_string_literal: true

module Mutations
  module SecurityPolicy
    class CreateScanExecutionPolicy < BaseMutation
      include FindsProject

      graphql_name 'CreateScanExecutionPolicy'

      authorize :add_project_to_instance_security_dashboard

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Full path of the project.'

      argument :policy_yaml, GraphQL::STRING_TYPE,
               required: true,
               description: 'YAML snippet of the policy..'

      field :merge_request_url,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'URL for the merge request.'

      def resolve(args)
        project = authorized_find!(args[:project_path])
        result = create_policy(project, args[:policy_yaml])
        error_message = result[:status] == :error ? result[:message] : nil

        {
          merge_request_url: error_message.nil? ? Gitlab::UrlBuilder.build(result[:merge_request]) : nil,
          errors: error_message
        }
      end

      private

      def create_policy(project, policy_yaml)
        ::Security::SecurityOrchestrationPolicies::PolicyCreateService
          .new(project: project, current_user: current_user, params: { policy_yaml: policy_yaml })
          .execute
      end
    end
  end
end
