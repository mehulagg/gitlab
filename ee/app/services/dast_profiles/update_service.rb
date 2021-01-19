# frozen_string_literal: true

module DastProfiles
  class CreateService < BaseContainerService
    MissingParamError = Class.new(StandardError)

    def execute
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      dast_profile = find_dast_profile!
      dast_profile.update!(dast_profile_params)

      ServiceResponse.success(payload: dast_profile)

    rescue ActiveRecord::RecordNotFound => err
      ServiceResponse.error(message: "#{err.model} not found")
    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    rescue MissingParamError => err
      ServiceResponse.error(message: err.message)
    end

    private

    def allowed?
      container.feature_available?(:security_on_demand_scans) &&
        Feature.enabled?(:dast_saved_scans, container, default_enabled: :yaml)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def find_dast_profile!
      id = params[:id] || raise(MissingParamError, 'ID parameter is missing')

      DastProfilesFinder.new(project_id: container.id, id: id).execute.first!
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def dast_profile_params
      params.slice(:dast_site_profile_id, :dast_scanner_profile_id, :name, :description)
    end
  end
end
