# frozen_string_literal: true

module Resolvers
  class DastSiteValidationResolver < BaseResolver
    alias_method :project, :synchronized_object

    type Types::DastSiteValidationType.connection_type, null: true

    argument :normalized_target_urls, [GraphQL::STRING_TYPE], required: false,
             description: 'Normalized URL of the target to be scanned'

    when_single do
      argument :target_url, GraphQL::STRING_TYPE, required: true,
               description: 'URL of the target to be scanned'
    end

    def resolve(**args)
      return DastSiteValidation.none unless allowed?

      DastSiteValidationsFinder.new(project_id: project.id, url_base: url_base(args), most_recent: true).execute
    end

    private

    def allowed?
      ::Feature.enabled?(:security_on_demand_scans_site_validation, project)
    end

    def url_base(args)
      return DastSiteValidation.get_normalized_url_base(args[:target_url]) if args[:target_url]

      args[:normalized_target_urls]
    end
  end
end
