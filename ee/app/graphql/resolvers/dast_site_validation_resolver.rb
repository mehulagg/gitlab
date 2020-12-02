# frozen_string_literal: true

module Resolvers
  class DastSiteValidationResolver < BaseResolver
    alias_method :project, :synchronized_object

    type Types::DastSiteValidationType.connection_type, null: true

    def resolve(**args)
      unless ::Feature.enabled?(:security_on_demand_scans_site_validation, project)
        raise ::Gitlab::Graphql::Errors::ResourceNotAvailable, 'Feature disabled'
      end

      url_base = DastSiteValidation.get_normalized_url_base(args[:target_url])
      DastSiteValidationsFinder.new(project_id: project.id, url_base: url_base).execute.first
    end
  end
end
