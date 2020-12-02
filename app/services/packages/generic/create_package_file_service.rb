# frozen_string_literal: true

module Packages
  module Generic
    class CreatePackageFileService < BaseService
      def execute
        ::Packages::Package.transaction do
          existing_package_file = find_existing_package_file
          result = create_package_file(find_or_create_package)
          remove_existing_package_file(existing_package_file) if params[:replace] && existing_package_file
          result
        end
      end

      private

      def find_or_create_package
        package_params = {
          name: params[:package_name],
          version: params[:package_version],
          build: params[:build]
        }

        ::Packages::Generic::FindOrCreatePackageService
          .new(project, current_user, package_params)
          .execute
      end

      def create_package_file(package)
        file_params = {
          file: params[:file],
          size: params[:file].size,
          file_sha256: params[:file].sha256,
          file_name: params[:file_name],
          build: params[:build]
        }

        ::Packages::CreatePackageFileService.new(package, file_params).execute
      end

      def find_existing_package_file
        ::Packages::PackageFileFinder
          .new(project, params[:file_name]).execute
      end

      def remove_existing_package_file(package_file)
        return unless package_file

        ::Packages::RemovePackageFileService.new(package_file).execute
      end
    end
  end
end
