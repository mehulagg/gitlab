# frozen_string_literal: true
#
# NuGet Package Manager Client API
#
# These API endpoints are not consumed directly by users, so there is no documentation for the
# individual endpoints. They are called by the NuGet package manager client when users run commands
# like `nuget install` or `nuget push`. The usage of the GitLab NuGet registry is documented here:
# https://docs.gitlab.com/ee/user/packages/nuget_repository/
#
# Technical debt: https://gitlab.com/gitlab-org/gitlab/issues/35798
module API
  module Concerns
    module Packages
      module NugetEndpoints
        extend ActiveSupport::Concern

        POSITIVE_INTEGER_REGEX = %r{\A[1-9]\d*\z}.freeze
        NON_NEGATIVE_INTEGER_REGEX = %r{\A0|[1-9]\d*\z}.freeze

        included do
          helpers do
            def find_packages
              packages = package_finder.execute

              not_found!('Packages') unless packages.exists?

              packages
            end

            def find_package
              package = package_finder(package_version: params[:package_version]).execute
                                                                                 .first

              not_found!('Package') unless package

              package
            end

            def package_finder(finder_params = {})
              ::Packages::Nuget::PackageFinder.new(
                authorized_user_project,
                **finder_params.merge(package_name: params[:package_name])
              )
            end
          end

          # https://docs.microsoft.com/en-us/nuget/api/service-index
          desc 'The NuGet Service Index' do
            detail 'This feature was introduced in GitLab 12.6'
          end

          route_setting :authentication, deploy_token_allowed: true, job_token_allowed: :basic_auth, basic_auth_personal_access_token: true

          get 'index', format: :json do
            authorize_read_package!(authorized_user_project)
            track_package_event('cli_metadata', :nuget, category: 'API::NugetPackages')

            present ::Packages::Nuget::ServiceIndexPresenter.new(authorized_user_project),
              with: ::API::Entities::Nuget::ServiceIndex
          end

          # https://docs.microsoft.com/en-us/nuget/api/registration-base-url-resource
          params do
            requires :package_name, type: String, desc: 'The NuGet package name', regexp: API::NO_SLASH_URL_PART_REGEX
          end
          namespace '/metadata/*package_name' do
            before do
              authorize_read_package!(authorized_user_project)
            end

            desc 'The NuGet Metadata Service - Package name level' do
              detail 'This feature was introduced in GitLab 12.8'
            end

            route_setting :authentication, deploy_token_allowed: true, job_token_allowed: :basic_auth, basic_auth_personal_access_token: true

            get 'index', format: :json do
              present ::Packages::Nuget::PackagesMetadataPresenter.new(find_packages),
                      with: ::API::Entities::Nuget::PackagesMetadata
            end

            desc 'The NuGet Metadata Service - Package name and version level' do
              detail 'This feature was introduced in GitLab 12.8'
            end
            params do
              requires :package_version, type: String, desc: 'The NuGet package version', regexp: API::NO_SLASH_URL_PART_REGEX
            end

            route_setting :authentication, deploy_token_allowed: true, job_token_allowed: :basic_auth, basic_auth_personal_access_token: true

            get '*package_version', format: :json do
              present ::Packages::Nuget::PackageMetadataPresenter.new(find_package),
                      with: ::API::Entities::Nuget::PackageMetadata
            end
          end

          # https://docs.microsoft.com/en-us/nuget/api/search-query-service-resource
          params do
            requires :q, type: String, desc: 'The search term'
            optional :skip, type: Integer, desc: 'The number of results to skip', default: 0, regexp: NON_NEGATIVE_INTEGER_REGEX
            optional :take, type: Integer, desc: 'The number of results to return', default: Kaminari.config.default_per_page, regexp: POSITIVE_INTEGER_REGEX
            optional :prerelease, type: ::Grape::API::Boolean, desc: 'Include prerelease versions', default: true
          end
          namespace '/query' do
            before do
              authorize_read_package!(authorized_user_project)
            end

            desc 'The NuGet Search Service' do
              detail 'This feature was introduced in GitLab 12.8'
            end

            route_setting :authentication, deploy_token_allowed: true, job_token_allowed: :basic_auth, basic_auth_personal_access_token: true

            get format: :json do
              search_options = {
                include_prerelease_versions: params[:prerelease],
                per_page: params[:take],
                padding: params[:skip]
              }
              search = ::Packages::Nuget::SearchService
                .new(authorized_user_project, params[:q], search_options)
                .execute

              track_package_event('search_package', :nuget, category: 'API::NugetPackages')

              present ::Packages::Nuget::SearchResultsPresenter.new(search),
                with: ::API::Entities::Nuget::SearchResults
            end
          end
        end
      end
    end
  end
end
