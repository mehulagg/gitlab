# frozen_string_literal: true

module Resolvers
  class NetworkPolicyResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource

    type Types::NetworkPolicyType, null: true
    authorize :read_threat_monitoring

    argument :environment_id,
             ::Types::GlobalIDType[::Environment],
             required: false,
             description: 'The global ID of the environment to filter policies.'

    alias_method :project, :object

    def resolve(**args)
      result = NetworkPolicies::ResourcesService.new(project: project, environment_id: args[:environment_id]).execute
      raise Gitlab::Graphql::Errors::BaseError, result.message unless result.success?

      result.payload.map do |policy|
        {
          name: policy.name,
          namespace: policy.namespace,
          updated_at: policy.creation_timestamp,
          yaml: policy.manifest,
          from_auto_devops: policy.autodevops?,
          enabled: policy.enabled?
        }
      end
    end
  end
end
