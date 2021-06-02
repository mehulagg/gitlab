# frozen_string_literal: true

module AppSec
  module Dast
    module Variables
      class FetchService < BaseContainerService
        def execute
          return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

          ServiceResponse.success(payload: scanner_profile_variables)
        end

        private

        def allowed?
          container.licensed_feature_available?(:security_on_demand_scans) &&
            ::Feature.enabled?(:dast_configuration_ui, container)
        end

        def scanner_profile_variables
          collection = ::Gitlab::Ci::Variables::Collection.new
          return collection unless params[:dast_scanner_profile_name]

          profile = DastScannerProfilesFinder.new(project_ids: [container.id], name: params[:dast_scanner_profile_name]).execute.first
          return collection unless profile

          profile.ci_variables
        end
      end
    end
  end
end
