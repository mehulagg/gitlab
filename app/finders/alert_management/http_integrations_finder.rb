# frozen_string_literal: true

module AlertManagement
  class HttpIntegrationsFinder
    def initialize(current_user, project, params)
      @current_user = current_user
      @project = project
      @params = params
    end

    def execute(skip_authorization: false)
      return HttpIntegration.none unless authorized? || skip_authorization

      @collection = project.alert_management_http_integrations

      filter_by_availability
      filter_by_id
      filter_by_endpoint_identifier
      filter_by_active

      collection
    end

    private

    attr_reader :current_user, :project, :params, :collection

    def authorized?
      Ability.allowed?(current_user, :admin_operations, project)
    end

    def filter_by_availability
      return if multiple_alert_http_integrations?

      @collection = collection.id_in(project.alert_management_http_integrations.first&.id)
    end

    def filter_by_id
      return unless params[:id]

      @collection = collection.id_in(params[:id])
    end

    def filter_by_endpoint_identifier
      return unless params[:endpoint_identifier]

      @collection = collection.for_endpoint_identifier(params[:endpoint_identifier])
    end

    def filter_by_active
      return unless params[:active]

      @collection = collection.active
    end

    # Overridden in EE
    def multiple_alert_http_integrations?
      false
    end
  end
end

::AlertManagement::HttpIntegrationsFinder.prepend_if_ee('EE::AlertManagement::HttpIntegrationsFinder')
