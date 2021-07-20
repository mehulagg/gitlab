# frozen_string_literal: true

module Resolvers
  module Admin
    module CloudLicenses
      class CurrentLicenseResolver < BaseResolver
        include Gitlab::Graphql::Authorize::AuthorizeResource
        include ::Admin::LicenseRequest

        type ::Types::Admin::CloudLicenses::CurrentLicenseType, null: true

        def resolve
          authorize!

          license
        end

        private

        def authorize!
          Ability.allowed?(context[:current_user], :read_licenses) || raise_resource_not_available_error!
        end
      end
    end
  end
end
