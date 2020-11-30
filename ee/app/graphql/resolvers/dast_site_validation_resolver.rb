# frozen_string_literal: true

module Resolvers
  class DastSiteValidationResolver < BaseResolver
    alias_method :project, :synchronized_object

    type Types::DastSiteValidationType.connection_type, null: true

    argument :normalized_target_url, GraphQL::STRING_TYPE, required: false,
             description: 'Normalized URL of the target to be scanned'

    when_single do
      argument :target_url, GraphQL::STRING_TYPE, required: true,
               description: 'URL of the target to be scanned'
    end

    def resolve(**args)
      unless ::Feature.enabled?(:security_on_demand_scans_site_validation, project)
        raise ::Gitlab::Graphql::Errors::ResourceNotAvailable, 'Feature disabled'
      end

      if args[:target_url]
        url_base = DastSiteValidation.get_normalized_url_base(args[:target_url])
        DastSiteValidationsFinder.new(project_id: project.id, url_base: url_base).execute
      else
        DastSiteValidationsFinder.new(project_id: project.id, url_base: args[:normalized_target_url]).execute
      end
    end
  end
end
