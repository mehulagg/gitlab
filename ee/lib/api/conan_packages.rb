# frozen_string_literal: true

module API
  class ConanPackages < Grape::API
    helpers ::API::Helpers::PackagesHelpers

    PACKAGE_REQUIREMENTS = {
      package_name: API::NO_SLASH_URL_PART_REGEX,
      package_version: API::NO_SLASH_URL_PART_REGEX,
      package_username: API::NO_SLASH_URL_PART_REGEX,
      package_channel: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    FILE_NAME_REQUIREMENTS = {
      file_name: Gitlab::Regex.conan_file_name_regex
    }.freeze

    PACKAGE_COMPONENT_REGEX = Gitlab::Regex.conan_recipe_component_regex

    before do
      not_found! unless Feature.enabled?(:conan_package_registry)
      require_packages_enabled!

      # Personal access token will be extracted from Bearer or Basic authorization
      # in the overridden find_personal_access_token helper
      authenticate!
    end

    namespace 'packages/conan/v1' do
      desc 'Ping the Conan API' do
        detail 'This feature was introduced in GitLab 12.2'
      end
      get 'ping' do
        header 'X-Conan-Server-Capabilities', [].join(',')
      end

      desc 'Search for packages' do
        detail 'This feature was introduced in GitLab 12.4'
      end
      params do
        requires :q, type: String, desc: 'Search query'
      end
      get 'conans/search' do
        service = ::Packages::Conan::SearchService.new(current_user, query: params[:q]).execute
        service.payload
      end

      namespace 'users' do
        format :txt

        desc 'Authenticate user against conan CLI' do
          detail 'This feature was introduced in GitLab 12.2'
        end
        get 'authenticate' do
          token = ::Gitlab::ConanToken.from_personal_access_token(access_token)
          token.to_jwt
        end

        desc 'Check for valid user credentials per conan CLI' do
          detail 'This feature was introduced in GitLab 12.4'
        end
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
        get 'packages/:conan_package_reference' do
          authorize!(:read_package, project)

          presenter = ConanPackagePresenter.new(recipe, current_user, project)

          present presenter, with: EE::API::Entities::ConanPackage::ConanPackageSnapshot
        end

        desc 'Recipe Snapshot' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        get do
          authorize!(:read_package, project)

          presenter = ConanPackagePresenter.new(recipe, current_user, project)

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
        get 'packages/:conan_package_reference/digest' do
          authorize!(:read_package, project)

          presenter = ConanPackagePresenter.new(recipe, current_user, project)

          render_api_error!("No recipe manifest found", 404) if presenter.package_urls.empty?

          present presenter, with: EE::API::Entities::ConanPackage::ConanPackageManifest
        end

        desc 'Recipe Digest' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        get 'digest' do
          authorize!(:read_package, project)

          presenter = ConanPackagePresenter.new(recipe, current_user, project)

          render_api_error!("No recipe manifest found", 404) if presenter.recipe_urls.empty?

          present presenter, with: EE::API::Entities::ConanPackage::ConanRecipeManifest
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
        post 'packages/:conan_package_reference/upload_urls' do
          authorize!(:read_package, project)

          status 200
          upload_urls = package_upload_urls(::Packages::ConanFileMetadatum::PACKAGE_FILES)

          present upload_urls, with: EE::API::Entities::ConanPackage::ConanUploadUrls
        end

        desc 'Recipe Upload Urls' do
          detail 'This feature was introduced in GitLab 12.4'
        end
        post 'upload_urls' do
          authorize!(:read_package, project)

          status 200
          upload_urls = recipe_upload_urls(::Packages::ConanFileMetadatum::RECIPE_FILES)

          present upload_urls, with: EE::API::Entities::ConanPackage::ConanUploadUrls
        end
      end

      params do
        requires :package_name, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package name'
        requires :package_version, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package version'
        requires :package_username, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package username'
        requires :package_channel, type: String, regexp: PACKAGE_COMPONENT_REGEX, desc: 'Package channel'
        requires :recipe_revision, type: String, desc: 'Conan Recipe Revision'
      end
      namespace 'files/:package_name/:package_version/:package_username/:package_channel/:recipe_revision' do
        before do
          authenticate_non_get!
        end

        params do
          requires :file_name, type: String, desc: 'Package file name'
        end
        desc 'Download recipe files' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        get 'export/:file_name' do
          not_found!
        end

        params do
          requires :conan_package_reference, type: String, desc: 'Conan Package ID'
          requires :package_revision, type: String, desc: 'Conan Package Revision'
          requires :file_name, type: String, desc: 'Package file name'
        end
        desc 'Download package files' do
          detail 'This feature was introduced in GitLab 12.5'
        end
        get 'package/:conan_package_reference/:package_revision/:file_name' do
          not_found!
        end
      end
    end

    helpers do
      include Gitlab::Utils::StrongMemoize
      include ::API::Helpers::RelatedResourcesHelpers

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

      def find_personal_access_token
        personal_access_token = find_personal_access_token_from_conan_jwt ||
          find_personal_access_token_from_conan_http_basic_auth

        personal_access_token || unauthorized!
      end

      # We need to override this one because it
      # looks into Bearer authorization header
      def find_oauth_access_token
      end

      def find_personal_access_token_from_conan_jwt
        jwt = Doorkeeper::OAuth::Token.from_bearer_authorization(current_request)
        return unless jwt

        token = ::Gitlab::ConanToken.decode(jwt)
        return unless token&.personal_access_token_id && token&.user_id

        PersonalAccessToken.find_by_id_and_user_id(token.personal_access_token_id, token.user_id)
      end

      def find_personal_access_token_from_conan_http_basic_auth
        encoded_credentials = headers['Authorization'].to_s.split('Basic ', 2).second
        token = Base64.decode64(encoded_credentials || '').split(':', 2).second
        return unless token

        PersonalAccessToken.find_by_token(token)
      end
    end
  end
end
