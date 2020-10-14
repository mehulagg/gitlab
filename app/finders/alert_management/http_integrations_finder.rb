# frozen_string_literal: true

module AlertManagement
  class HttpIntegrationsFinder
    def initialize(project, params)
      @project = project
      @params = params
    end

    def execute
      collection = project.alert_management_http_integrations
      collection = by_availability(collection)
      collection = by_endpoint_identifier(collection)
      by_active(collection)
    end

    private

    attr_reader :project, :params

    # Overridden in EE
    def by_availability(collection)
      collection.limit(1) # rubocop: disable CodeReuse/ActiveRecord
    end

    def by_endpoint_identifier(collection)
      return collection unless params[:endpoint_identifier]

      collection.for_endpoint_identifier(params[:endpoint_identifier])
    end

    def by_active(collection)
      return collection unless params[:active]

      collection.active
    end
  end
end

::AlertManagement::HttpIntegrationsFinder.prepend_if_ee('EE::AlertManagement::HttpIntegrationsFinder')
