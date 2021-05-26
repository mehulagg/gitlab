# frozen_string_literal: true

module AppSec
  module Dast
    module Profiles
      module Audit
        class UpdateService < BaseContainerService
          def execute
            params[:new_params].each do |property, new_value|
              old_value = params[:old_params][property]

              next if old_value == new_value

              ::Gitlab::Audit::Auditor.audit(
                name: 'dast_profile_update',
                author: current_user,
                scope: container,
                target: params[:dast_profile],
                message: audit_message(property, new_value, old_value)
              )
            end
          end

          private

          def audit_message(property, new_value, old_value)
            case property
            when :dast_scanner_profile_id
              new_value = DastScannerProfile.find(new_value).name
              old_value = DastScannerProfile.find(old_value).name
              property = :dast_scanner_profile
            when :dast_site_profile_id
              new_value = DastSiteProfile.find(new_value).name
              old_value = DastSiteProfile.find(old_value).name
              property = :dast_site_profile
            end

            "Changed DAST profile #{property} from #{old_value} to #{new_value}"
          end
        end
      end
    end
  end
end
