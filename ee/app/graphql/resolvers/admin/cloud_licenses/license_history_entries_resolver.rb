# frozen_string_literal: true

module Resolvers
  module Admin
    module CloudLicenses
      class LicenseHistoryEntriesResolver < BaseResolver
        type [::Types::Admin::CloudLicenses::LicenseHistoryEntryType.connection_type], null: true

        def resolve
          return unless application_settings.cloud_license_enabled?

          authorize!

          License.history
        end

        private

        def application_settings
          return if ::Gitlab.com?

          Gitlab::CurrentSettings.current_application_settings
        end

        def authorize!
          admin? || raise_resource_not_available_error!
        end

        def admin?
          context[:current_user].present? && context[:current_user].admin?
        end
      end
    end
  end
end
