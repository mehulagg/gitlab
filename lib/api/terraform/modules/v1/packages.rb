# frozen_string_literal: true

module API
  module Terraform
    module Modules
      module V1
        class Packages < ::API::Base
          include SendFileUpload

          SEMVER_REGEX = Gitlab::Regex.semver_regex.freeze

          TERRAFORM_MODULE_REQUIREMENTS = {
            module_namespace: API::NO_SLASH_URL_PART_REGEX,
            module_name: API::NO_SLASH_URL_PART_REGEX,
            module_system: API::NO_SLASH_URL_PART_REGEX
          }.freeze

          TERRAFORM_MODULE_VERSION_REQUIREMENTS = {
            module_version: SEMVER_REGEX
          }.freeze

          feature_category :package_registry

          route_setting :authentication, job_token_allowed: true, basic_auth_personal_access_token: true, deploy_token_allowed: true

          before do
            require_packages_enabled!
            authenticate!

            # require_generic_packages_available!
          end

          params do
            requires :module_namespace, type: String, regexp: API::NO_SLASH_URL_PART_REGEX, desc: "Group's ID or slug"
            requires :module_name, type: String, regexp: API::NO_SLASH_URL_PART_REGEX
            requires :module_system, type: String, regexp: API::NO_SLASH_URL_PART_REGEX
          end

          namespace 'packages/terraform/v1/modules/:module_namespace/:module_name/:module_system', requirements: TERRAFORM_MODULE_REQUIREMENTS do
            helpers do
              def module_namespace
                strong_memoize(:module_namespace) do
                  find_group!(params[:module_namespace])
                end
              end

              def packages
                strong_memoize(:packages) do
                  ::Packages::GroupPackagesFinder.new(
                    current_user,
                    module_namespace,
                    {
                      package_type: :terraform_module,
                      package_name: "#{params[:module_name]}/#{params[:module_system]}"
                    }
                  ).execute
                end
              end
            end

            get 'versions' do
              presenter = ::Terraform::ModulesPresenter.new(packages, params[:module_system])
              present presenter, with: ::API::Entities::Terraform::ModuleVersions
            end

            params do
              requires :module_version, type: String, regexp: SEMVER_REGEX
            end

            route_param :module_version, requirements: TERRAFORM_MODULE_VERSION_REQUIREMENTS do
              helpers do
                def package
                  strong_memoize(:package) do
                    packages.find { |package| package.version == params[:module_version] }
                  end
                end

                def package_file
                  strong_memoize(:package_file) do
                    package.package_files.first
                  end
                end
              end

              before do
                not_found! unless package
                not_found! unless package_file
                # authorize!(:read_package, package.project)
              end

              route_setting :authentication, job_token_allowed: true, basic_auth_personal_access_token: true, deploy_token_allowed: true

              get 'download' do
                module_file_path = api_v4_packages_terraform_v1_modules_file_path(
                  module_namespace: params[:module_namespace],
                  module_name: params[:module_name],
                  module_system: params[:module_system],
                  module_version: params[:module_version]
                )

                header 'X-Terraform-Get', module_file_path
                status :no_content
              end

              route_setting :authentication, job_token_allowed: true, basic_auth_personal_access_token: true, deploy_token_allowed: true

              get 'file' do
                present_carrierwave_file!(package_file.file)
              end
            end
          end

          resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
            namespace ':id/packages/terraform/modules' do
              namespace ':module_name/:module_system/:module_version/file' do
                # desc 'Download Terraform Module package file' do
                #   detail 'This feature was introduced in GitLab 13.10'
                # end

                # params do
                #   requires :module_name, type: String, desc: 'Module name', regexp: API::NO_SLASH_URL_PART_REGEX
                #   requires :module_system, type: String, desc: 'Module system', regexp: API::NO_SLASH_URL_PART_REGEX
                #   requires :module_version, type: String, desc: 'Module version', regexp: SEMVER_REGEX
                # end

                # get do
                #   authorize!(:read_package, project)

                #   package_file = ::Packages::Conan::PackageFileFinder
                #     .new(
                #       package,
                #       params[:file_name].to_s,
                #       conan_file_type: file_type,
                #       conan_package_reference: params[:conan_package_reference]
                #     ).execute!

                #   present_carrierwave_file!(package_file.file)
                # end

                desc 'Workhorse authorize Terraform Module package file' do
                  detail 'This feature was introduced in GitLab 13.10'
                end

                params do
                  requires :module_name, type: String, desc: 'Module name', regexp: API::NO_SLASH_URL_PART_REGEX
                  requires :module_system, type: String, desc: 'Module system', regexp: API::NO_SLASH_URL_PART_REGEX
                  requires :module_version, type: String, desc: 'Module version', regexp: SEMVER_REGEX
                end

                put 'authorize' do
                  authorize_workhorse!(subject: project, maximum_size: project.actual_limits.generic_packages_max_file_size)
                end

                desc 'Upload Terraform Module package file' do
                  detail 'This feature was introduced in GitLab 13.10'
                end

                params do
                  requires :module_name, type: String, desc: 'Module name', regexp: API::NO_SLASH_URL_PART_REGEX
                  requires :module_system, type: String, desc: 'Module system', regexp: API::NO_SLASH_URL_PART_REGEX
                  requires :module_version, type: String, desc: 'Module version', regexp: SEMVER_REGEX
                  requires :file, type: ::API::Validations::Types::WorkhorseFile, desc: 'The package file to be published (generated by Multipart middleware)'
                end

                put do
                  authorize_upload!(project)
                  bad_request!('File is too large') if max_file_size_exceeded?

                  track_event('push_package')

                  create_package_file_params = declared_params.merge(build: current_authenticated_job)
                  result = ::Packages::TerraformModule::CreatePackageService
                    .new(project, current_user, create_package_file_params)
                    .execute

                  render_api_error!(result[:message], result[:http_status]) if result[:status] == :error

                  created!
                rescue ObjectStorage::RemoteStoreError => e
                  Gitlab::ErrorTracking.track_exception(e, extra: { file_name: params[:file_name], project_id: project.id })

                  forbidden!
                end
              end
            end
          end

          helpers do
            include ::API::Helpers::PackagesHelpers
            include ::API::Helpers::Packages::BasicAuthHelpers

            # def require_generic_packages_available!
            #   not_found! unless Feature.enabled?(:generic_packages, project, default_enabled: true)
            # end

            def project
              authorized_user_project
            end

            def max_file_size_exceeded?
              project.actual_limits.exceeded?(:generic_packages_max_file_size, params[:file].size)
            end
          end
        end
      end
    end
  end
end
