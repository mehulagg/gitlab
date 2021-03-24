# frozen_string_literal: true

module Resolvers
  module Admin
    module CloudLicenses
      class LicensesResolver < BaseResolver
        include Gitlab::Graphql::Authorize::AuthorizeResource
        include ::Admin::LicenseRequest

        type ::Types::Admin::CloudLicenses::LicenseType.connection_type, null: true

        def resolve
          return if ::Gitlab.com?
          return unless application_settings.cloud_license_enabled?

          authorize!

          license
        end

        private

        def application_settings
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
