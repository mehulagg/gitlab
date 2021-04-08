# frozen_string_literal: true

module Resolvers
  module Admin
    module CloudLicenses
      class LicenseHistoryEntriesResolver < BaseResolver
        include Gitlab::Graphql::Authorize::AuthorizeResource

        type [::Types::Admin::CloudLicenses::LicenseHistoryEntryType], null: true

        def resolve
          return unless application_settings.cloud_license_enabled?

          authorize!

          License.history
        end

        private

        def application_settings
          Gitlab::CurrentSettings.current_application_settings
        end

        def authorize!
          Ability.allowed?(context[:current_user], :read_licenses) || raise_resource_not_available_error!
        end
      end
    end
  end
end
