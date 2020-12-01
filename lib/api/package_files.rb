# frozen_string_literal: true

module API
  class PackageFiles < ::API::Base
    include PaginationParams

    before do
      authorize_packages_access!(user_project)
    end

    feature_category :package_registry

    helpers ::API::Helpers::PackagesHelpers

    params do
      requires :id, type: String, desc: 'The ID of a project'
      requires :package_id, type: Integer, desc: 'The ID of a package'
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get all package files' do
        detail 'This feature was introduced in GitLab 11.8'
        success ::API::Entities::PackageFile
      end

      params do
        use :pagination
      end

      desc 'List all package files' do
        success ::API::Entities::Package
      end
      get ':id/packages/:package_id/package_files' do
        package = ::Packages::PackageFinder
          .new(user_project, params[:package_id]).execute

        present paginate(package.package_files), with: ::API::Entities::PackageFile
      end

      desc 'List a package file' do
        detail 'This feature was introduced in GitLab 13.7'
        success ::API::Entities::PackageFile
      end
      params do
        requires :package_file_id, type: Integer, desc: 'The ID of a package file'
      end
      get ':id/packages/:package_id/package_files/:package_file_id' do
        package_file = ::Packages::PackageFileFinder
          .new(user_project, nil).by_id(params[:package_file_id])

        not_found!('PackageFile') unless package_file

        present package_file, with: ::API::Entities::PackageFile
      end

      desc 'Remove a package file' do
        detail 'This feature was introduced in GitLab 13.7'
      end
      params do
        requires :package_file_id, type: Integer, desc: 'The ID of a package file'
      end
      delete ':id/packages/:package_id/package_files/:package_file_id' do
        package_file = ::Packages::PackageFileFinder
          .new(user_project, nil).by_id(params[:package_file_id])

        not_found!('PackageFile') unless package_file

        destroy_conditionally!(package_file)
      end
    end
  end
end
