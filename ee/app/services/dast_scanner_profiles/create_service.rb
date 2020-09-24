# frozen_string_literal: true

module DastScannerProfiles
  class CreateService < BaseService
    def execute(name:, target_timeout:, spider_timeout:)
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      dast_scanner_profile = DastScannerProfile.create(
        project: project,
        name: name,
        target_timeout: target_timeout,
        spider_timeout: spider_timeout
      )
      return ServiceResponse.success(payload: dast_scanner_profile) if dast_scanner_profile.valid?

      ServiceResponse.error(message: dast_scanner_profile.errors.full_messages)
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
    end
  end
end
