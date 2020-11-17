# frozen_string_literal: true

# NuGet Package Manager Client API
#
# These API endpoints are not meant to be consumed directly by users. They are
# called by the NuGet package manager client when users run commands
# like `nuget install` or `nuget push`.
#
# This is the group level API.

module API
  class NugetGroupPackages < ::API::Base
    helpers ::API::Helpers::PackagesManagerClientsHelpers
    helpers ::API::Helpers::Packages::BasicAuthHelpers

    feature_category :package_registry

    default_format :json

    rescue_from ArgumentError do |e|
      render_api_error!(e.message, 400)
    end

    helpers do
      def project_or_group
        find_authorized_group!
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a group', regexp: ::API::Concerns::Packages::NugetEndpoints::POSITIVE_INTEGER_REGEX
    end

    route_setting :authentication, deploy_token_allowed: true, job_token_allowed: :basic_auth, basic_auth_personal_access_token: true

    resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      namespace ':id/packages/nuget' do
        include ::API::Concerns::Packages::NugetEndpoints
      end
    end
  end
end
