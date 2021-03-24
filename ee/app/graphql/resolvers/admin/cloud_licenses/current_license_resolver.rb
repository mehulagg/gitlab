# frozen_string_literal: true

module Resolvers
  module Admin
    module CloudLicenses
      class CurrentLicenseResolver < BaseResolver
        include Gitlab::Graphql::Authorize::AuthorizeResource
        include ::Admin::LicenseRequest

        type ::Types::Admin::CloudLicenses::CurrentLicenseType, null: true

        def resolve
          return if ::Gitlab.com?
          return unless application_settings.cloud_license_enabled?

          authorize!

          reset_license_caches

          License.current
        end

        private

        def application_settings
          Gitlab::CurrentSettings.current_application_settings
        end

        def authorize!
          Ability.allowed?(context[:current_user], :read_licenses) || raise_resource_not_available_error!
        end

        def reset_license_caches
          License.reset_current
          License.reset_future_dated
          License.reset_previous
        end
      end
    end
  end
end
