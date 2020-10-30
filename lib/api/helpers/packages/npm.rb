# frozen_string_literal: true

module API
  module Helpers
    module Packages
      module Npm
        include Gitlab::Utils::StrongMemoize

        NPM_ENDPOINT_REQUIREMENTS = {
          package_name: API::NO_SLASH_URL_PART_REGEX
        }.freeze

        def endpoint_scope
          params[:id].present? ? :project : :instance
        end

        def project
          strong_memoize(:project) do
            case endpoint_scope
            when :project
              user_project
            when :instance
              ::Packages::Package.npm.with_name(params[:package_name]).first&.project
            end
          end
        end
      end
    end
  end
end
