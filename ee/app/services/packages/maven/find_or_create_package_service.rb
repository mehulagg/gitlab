# frozen_string_literal: true
module Packages
  module Maven
    class FindOrCreatePackageService < ::ContainerBaseService
      MAVEN_METADATA_FILE = 'maven-metadata.xml'.freeze

      def execute
        package = ::Packages::Maven::PackageFinder
          .new(params[:path], current_user, project: project).execute

        unless package
          if params[:file_name] == MAVEN_METADATA_FILE
            # Maven uploads several files during `mvn deploy` in next order:
            #   - my-company/my-app/1.0-SNAPSHOT/my-app.jar
            #   - my-company/my-app/1.0-SNAPSHOT/my-app.pom
            #   - my-company/my-app/1.0-SNAPSHOT/maven-metadata.xml
            #   - my-company/my-app/maven-metadata.xml
            #
            # The last xml file does not have VERSION in URL because it contains
            # information about all versions.
            package_name, version = params[:path], nil
          else
            package_name, _, version = params[:path].rpartition('/')
          end

          package_params = {
            name: package_name,
            path: params[:path],
            version: version,
            build: params[:build]
          }

          package = ::Packages::Maven::CreatePackageService
            .new(project, current_user, package_params).execute
        end

        package
      end
    end
  end
end
