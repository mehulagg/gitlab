# frozen_string_literal: true

module API
  module Helpers
    module Packages
      module Npm
        include Gitlab::Utils::StrongMemoize
        include ::API::Helpers::PackagesHelpers

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
              project_id = ::Packages::Package.npm
                                              .with_name(params[:package_name])
                                              .first
                                              &.project_id

              not_found!('Project') unless project_id

              find_project!(project_id)
            end
          end
        end

        def project_or_nil
          strong_memoize(:project_or_nil) do
            case endpoint_scope
            when :project
              find_project(params[:id])
            when :instance
              project_id = ::Packages::Package.npm
                                              .with_name(params[:package_name])
                                              .first
                                              &.project
            end
          end
        end
      end
    end
  end
end
