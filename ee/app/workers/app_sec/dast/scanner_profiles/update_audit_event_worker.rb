# frozen_string_literal: true

module AppSec
  module Dast
    module ScannerProfiles
      class UpdateAuditEventWorker
        include ApplicationWorker

        idempotent!

        feature_category :dynamic_application_security_testing

        def perform(user_id, project_id, profile_id, params, old_params)
          user = UserFinder.new(user_id).find_by_id
          project = ProjectsFinder.new(current_user: user, project_ids_relation: [project_id]).execute.first
          profile = DastScannerProfilesFinder.new(ids: [profile_id]).execute.first

          params.each do |property, new_value|
            old_value = old_params[property]

            next if old_value == new_value

            AuditEventService.new(user, project, {
              change: _('%{profile} %{property}') % { profile: humanize_profile(profile), property: property },
              from: old_value,
              to: new_value,
              target_id: profile.id,
              target_type: profile.class.name,
              target_details: profile.name
            }).security_event
          end
        end

        private

        def humanize_profile(profile)
          profile.class.name.underscore.humanize.sub('Dast', 'DAST')
        end
      end
    end
  end
end
