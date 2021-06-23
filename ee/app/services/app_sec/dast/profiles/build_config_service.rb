# frozen_string_literal: true

module AppSec
  module Dast
    module Profiles
      class BuildConfigService < BaseProjectService
        def execute
          return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

          ServiceResponse.success(payload: { dast_site_profile: site_profile, dast_scanner_profile: scanner_profile })
        end

        private

        def allowed?
          container.licensed_feature_available?(:security_on_demand_scans)
        end

        def site_profile
          fetch_profile(params[:dast_site_profile]) do |name|
            DastSiteProfilesFinder.new(project_id: container.id, name: name)
          end
        end

        def scanner_profile
          fetch_profile(params[:dast_scanner_profile]) do |name|
            DastScannerProfilesFinder.new(project_ids: [container.id], name: name)
          end
        end

        def fetch_profile(name)
          return unless name

          profile = yield(name).execute.first

          return unless can?(current_user, :read_on_demand_scans, profile)

          profile
        end
      end
    end
  end
end
