# frozen_string_literal: true

# Conan Package Manager Client API
#
# These API endpoints are not consumed directly by users, so there is no documentation for the
# individual endpoints. They are called by the Conan package manager client when users run commands
# like `conan install` or `conan upload`. The usage of the GitLab Conan repository is documented here:
# https://docs.gitlab.com/ee/user/packages/conan_repository/#installing-a-package
#
# Technical debt: https://gitlab.com/gitlab-org/gitlab/issues/35798
module API
  class ConanPackages < Grape::API
    helpers ::API::Helpers::PackagesManagerClientsHelpers

    PACKAGE_REQUIREMENTS = {
      package_name: API::NO_SLASH_URL_PART_REGEX,
      package_version: API::NO_SLASH_URL_PART_REGEX,
      package_username: API::NO_SLASH_URL_PART_REGEX,
      package_channel: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    FILE_NAME_REQUIREMENTS = {
      file_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    PACKAGE_COMPONENT_REGEX = Gitlab::Regex.conan_recipe_component_regex
    CONAN_REVISION_REGEX = Gitlab::Regex.conan_revision_regex

    before do
      require_packages_enabled!

      # Personal access token will be extracted from Bearer or Basic authorization
      # in the overridden find_personal_access_token or find_user_from_job_token helpers
      authenticate!
    end

    namespace 'packages/conan/v1' do
      desc 'Ping the Conan API' do
        detail 'This feature was introduced in GitLab 12.2'
      end
      route_setting :authentication, job_token_allowed: true
      get 'ping' do
        header 'X-Conan-Server-Capabilities', [].join(',')
      end

      desc 'Search for packages' do
        detail 'This feature was introduced in GitLab 12.4'
      end
      params do
        requires :q, type: String, desc: 'Search query'
      end
      route_setting :authentication, job_token_allowed: true
      get 'conans/search' do
        service = ::Packages::Conan::SearchService.new(current_user, query: params[:q]).execute
        service.payload
      end

      namespace 'users' do
        format :txt

        desc 'Authenticate user against conan CLI' do
          detail 'This feature was introduced in GitLab 12.2'
        end
        route_setting :authentication, job_token_allowed: true
        get 'authenticate' do
          token = if access_token
                    ::Gitlab::ConanToken.from_personal_access_token(access_token)
                  else
                    ::Gitlab::ConanToken.from_job(find_job_from_token)
                  end

          token.to_jwt
        end

        desc 'Check for valid user credentials per conan CLI' do
          detail 'This feature was introduced in GitLab 12.4'
        end
        route_setting :authentication, job_token_allowed: true
        get 'check_credentials' do
          authenticate!
          :ok
        end
      end

      params do
        requires :package_name, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package name'
        requires :package_version, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package version'
        requires :package_username, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package username'
        requires :package_channel, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package channel'
      end
      namespace 'conans/:package_name/:package_version/:package_username/:package_channel', requirements: PACKAGE_REQUIREMENTS do
        # Get the snapshot
        #
        # the snapshot is a hash of { filename: md5 hash }
        # md5 hash is the has of that file. This hash is used to diff the files existing on the client
        # to determine which client files need to be uploaded if no recipe exists the snapshot is empty
        desc 'Package Snapshot' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        route_setting :authentication, job_token_allowed: true
        get 'packages/:conan_package_reference' do
          authorize!(:read_package, project)

          presenter = ::Packages::Conan::PackagePresenter.new(recipe, current_user, project)

          present presenter, with: EE::API::Entities::ConanPackage::ConanPackageSnapshot
        end

        desc 'Recipe Snapshot' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        route_setting :authentication, job_token_allowed: true
        get do
          authorize!(:read_package, project)

          presenter = ::Packages::Conan::PackagePresenter.new(recipe, current_user, project)

          present presenter, with: EE::API::Entities::ConanPackage::ConanRecipeSnapshot
        end

        # Get the manifest
        # returns the download urls for the existing recipe in the registry
        #
        # the manifest is a hash of { filename: url }
        # where the url is the download url for the file
        desc 'Package Digest' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        route_setting :authentication, job_token_allowed: true
        get 'packages/:conan_package_reference/digest' do
          present_package_download_urls
        end

        desc 'Recipe Digest' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        route_setting :authentication, job_token_allowed: true
        get 'digest' do
          present_recipe_download_urls
        end

        # Get the download urls
        #
        # returns the download urls for the existing recipe or package in the registry
        #
        # the manifest is a hash of { filename: url }
        # where the url is the download url for the file
        desc 'Package Download Urls' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        route_setting :authentication, job_token_allowed: true
        get 'packages/:conan_package_reference/download_urls' do
          present_package_download_urls
        end

        desc 'Recipe Download Urls' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        route_setting :authentication, job_token_allowed: true
        get 'download_urls' do
          present_recipe_download_urls
        end

        # Get the upload urls
        #
        # request body contains { filename: filesize } where the filename is the
        # name of the file the conan client is requesting to upload
        #
        # returns { filename: url }
        # where the url is the upload url for the file that the conan client will use
        desc 'Package Upload Urls' do
          detail 'This feature was introduced in GitLab 12.4'
        end
        params do
          requires :conan_package_reference, type: String, desc: 'Conan package ID'
        end
        route_setting :authentication, job_token_allowed: true
        post 'packages/:conan_package_reference/upload_urls' do
          authorize!(:read_package, project)

          status 200
          upload_urls = package_upload_urls(::Packages::ConanFileMetadatum::PACKAGE_FILES)

          present upload_urls, with: EE::API::Entities::ConanPackage::ConanUploadUrls
        end

        desc 'Recipe Upload Urls' do
          detail 'This feature was introduced in GitLab 12.4'
        end
        route_setting :authentication, job_token_allowed: true
        post 'upload_urls' do
          authorize!(:read_package, project)

          status 200
          upload_urls = recipe_upload_urls(::Packages::ConanFileMetadatum::RECIPE_FILES)

          present upload_urls, with: EE::API::Entities::ConanPackage::ConanUploadUrls
        end

        desc 'Delete Package' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        route_setting :authentication, job_token_allowed: true
        delete do
          authorize!(:destroy_package, project)

          track_event('delete_package')

          package.destroy
        end
      end

      params do
        requires :package_name, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package name'
        requires :package_version, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package version'
        requires :package_username, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package username'
        requires :package_channel, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package channel'
        requires :recipe_revision, type: String, regexp: CONAN_REVISION_REGEX, desc: 'Conan Recipe Revision'
      end
      namespace 'files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision', requirements: PACKAGE_REQUIREMENTS do
        before do
          authenticate_non_get!
        end

        params do
          requires :file_name, type: String, desc: 'Package file name', regexp: Gitlab::Regex.conan_file_name_regex
        end
        namespace 'export/:file_name', requirements: FILE_NAME_REQUIREMENTS do
          desc 'Download recipe files' do
            detail 'This feature was introduced in GitLab 12.6'
          end
          route_setting :authentication, job_token_allowed: true
          get do
            download_package_file(:recipe_file)
          end

          desc 'Upload recipe package files' do
            detail 'This feature was introduced in GitLab 12.6'
          end
          params do
            use :workhorse_upload_params
          end
          route_setting :authentication, job_token_allowed: true
          put do
            upload_package_file(:recipe_file)
          end

          desc 'Workhorse authorize the conan recipe file' do
            detail 'This feature was introduced in GitLab 12.6'
          end
          route_setting :authentication, job_token_allowed: true
          put 'authorize' do
            authorize_workhorse!(subject: project)
          end
        end

        params do
          requires :conan_package_reference, type: String, desc: 'Conan Package ID'
          requires :package_revision, type: String, desc: 'Conan Package Revision'
          requires :file_name, type: String, desc: 'Package file name', regexp: Gitlab::Regex.conan_file_name_regex
        end
        namespace 'package/:conan_package_reference/:package_revision/:file_name', requirements: FILE_NAME_REQUIREMENTS do
          desc 'Download package files' do
            detail 'This feature was introduced in GitLab 12.5'
          end
          route_setting :authentication, job_token_allowed: true
          get do
            download_package_file(:package_file)
          end

          desc 'Workhorse authorize the conan package file' do
            detail 'This feature was introduced in GitLab 12.6'
          end
          route_setting :authentication, job_token_allowed: true
          put 'authorize' do
            authorize_workhorse!(subject: project)
          end

          desc 'Upload package files' do
            detail 'This feature was introduced in GitLab 12.6'
          end
          params do
            use :workhorse_upload_params
          end
          route_setting :authentication, job_token_allowed: true
          put do
            upload_package_file(:package_file)
          end
        end
      end
    end

    helpers do
      include Gitlab::Utils::StrongMemoize
      include ::API::Helpers::RelatedResourcesHelpers

      def present_download_urls(entity)
        authorize!(:read_package, project)

        presenter = ::Packages::Conan::PackagePresenter.new(recipe, current_user, project)

        render_api_error!("No recipe manifest found", 404) if yield(presenter).empty?

        present presenter, with: entity
      end

      def present_package_download_urls
        present_download_urls(EE::API::Entities::ConanPackage::ConanPackageManifest, &:package_urls)
      end

      def present_recipe_download_urls
        present_download_urls(EE::API::Entities::ConanPackage::ConanRecipeManifest, &:recipe_urls)
      end

      def recipe_upload_urls(file_names)
        { upload_urls: Hash[
          file_names.collect do |file_name|
            [file_name, recipe_file_upload_url(file_name)]
          end
        ] }
      end

      def package_upload_urls(file_names)
        { upload_urls: Hash[
          file_names.collect do |file_name|
            [file_name, package_file_upload_url(file_name)]
          end
        ] }
      end

      def package_file_upload_url(file_name)
        expose_url(
          api_v4_packages_conan_v1_files_package_path(
            package_name: params[:package_name],
            package_version: params[:package_version],
            package_username: params[:package_username],
            package_channel: params[:package_channel],
            recipe_revision: '0',
            conan_package_reference: params[:conan_package_reference],
            package_revision: '0',
            file_name: file_name
          )
        )
      end

      def recipe_file_upload_url(file_name)
        expose_url(
          api_v4_packages_conan_v1_files_export_path(
            package_name: params[:package_name],
            package_version: params[:package_version],
            package_username: params[:package_username],
            package_channel: params[:package_channel],
            recipe_revision: '0',
            file_name: file_name
          )
        )
      end

      def recipe
        "%{package_name}/%{package_version}@%{package_username}/%{package_channel}" % params.symbolize_keys
      end

      def project
        strong_memoize(:project) do
          full_path = ::Packages::ConanMetadatum.full_path_from(package_username: params[:package_username])
          Project.find_by_full_path(full_path)
        end
      end

      def package
        strong_memoize(:package) do
          project.packages
            .with_name(params[:package_name])
            .with_version(params[:package_version])
            .with_conan_channel(params[:package_channel])
            .order_created
            .last
        end
      end

      def download_package_file(file_type)
        authorize!(:read_package, project)

        package_file = ::Packages::PackageFileFinder
          .new(package, "#{params[:file_name]}", conan_file_type: file_type).execute!

        track_event('pull_package') if params[:file_name] == ::Packages::ConanFileMetadatum::PACKAGE_BINARY

        present_carrierwave_file!(package_file.file)
      end

      def find_or_create_package
        package || ::Packages::Conan::CreatePackageService.new(project, current_user, params).execute
      end

      def track_push_package_event
        if params[:file_name] == ::Packages::ConanFileMetadatum::PACKAGE_BINARY && params['file.size'].positive?
          track_event('push_package')
        end
      end

      def create_package_file_with_type(file_type, current_package)
        unless params['file.size'] == 0
          # conan sends two upload requests, the first has no file, so we skip record creation if file.size == 0
          ::Packages::Conan::CreatePackageFileService.new(current_package, uploaded_package_file, params.merge(conan_file_type: file_type)).execute
        end
      end

      def upload_package_file(file_type)
        authorize_upload!(project)

        current_package = find_or_create_package

        track_push_package_event

        create_package_file_with_type(file_type, current_package)
      rescue ObjectStorage::RemoteStoreError => e
        Gitlab::ErrorTracking.track_exception(e, file_name: params[:file_name], project_id: project.id)

        forbidden!
      end

      def find_personal_access_token
        personal_access_token = find_personal_access_token_from_conan_jwt ||
          find_personal_access_token_from_http_basic_auth

        personal_access_token
      end

      def find_user_from_job_token
        return unless route_authentication_setting[:job_token_allowed]

        job = find_job_from_token || raise(::Gitlab::Auth::UnauthorizedError)

        job.user
      end

      def find_job_from_token
        find_job_from_conan_jwt || find_job_from_http_basic_auth
      end

      # We need to override this one because it
      # looks into Bearer authorization header
      def find_oauth_access_token
      end

      def find_personal_access_token_from_conan_jwt
        token = decode_oauth_token_from_jwt

        return unless token

        PersonalAccessToken.find_by_id_and_user_id(token.access_token_id, token.user_id)
      end

      def find_job_from_conan_jwt
        token = decode_oauth_token_from_jwt

        return unless token

        ::Ci::Build.find_by_token(token.access_token_id.to_s)
      end

      def decode_oauth_token_from_jwt
        jwt = Doorkeeper::OAuth::Token.from_bearer_authorization(current_request)

        return unless jwt

        token = ::Gitlab::ConanToken.decode(jwt)

        return unless token && token.access_token_id && token.user_id

        token
      end
    end
  end
end
