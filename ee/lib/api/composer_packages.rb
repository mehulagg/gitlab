# frozen_string_literal: true

# PHP composer support (https://getcomposer.org/)
module API
  class ComposerPackages < Grape::API::Instance
    helpers ::API::Helpers::PackagesManagerClientsHelpers
    helpers ::API::Helpers::RelatedResourcesHelpers
    helpers ::API::Helpers::Packages::BasicAuthHelpers
    include ::API::Helpers::Packages::BasicAuthHelpers::Constants
    include ::Gitlab::Utils::StrongMemoize

    content_type :json, 'application/json'
    default_format :json

    COMPOSER_ENDPOINT_REQUIREMENTS = {
      package_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    default_format :json

    rescue_from ArgumentError do |e|
      render_api_error!(e.message, 400)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_api_error!(e.message, 400)
    end

    helpers do
      def packages
        strong_memoize(:packages) do
          packages = ::Packages::Composer::PackagesFinder.new(current_user, user_group).execute

          if params[:package_name].present?
            packages = packages.with_name(params[:package_name])
          end

          packages
        end
      end

      def presenter
        @presenter ||= ::Packages::Composer::PackagesPresenter.new(user_group, packages)
      end
    end

    before do
      require_packages_enabled!
    end

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end

    resource :group, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      before do
        authorize_packages_feature!(user_group)
      end

      desc 'Composer packages endpoint at group level'

      route_setting :authentication, job_token_allowed: true

      get ':id/-/packages/composer/packages' do
        presenter.root
      end

      desc 'Composer packages endpoint at group level for packages list'

      params do
        requires :sha, type: String, desc: 'Shasum of current json'
      end

      route_setting :authentication, job_token_allowed: true

      get ':id/-/packages/composer/p/:sha' do
        presenter.provider
      end

      desc 'Composer packages endpoint at group level for package versions metadata'

      params do
        requires :package_name, type: String, file_path: true, desc: 'The Composer package name'
      end

      route_setting :authentication, job_token_allowed: true

      get ':id/-/packages/composer/*package_name', requirements: COMPOSER_ENDPOINT_REQUIREMENTS, file_path: true do
        not_found! if packages.empty?

        presenter.package_versions
      end
    end

    params do
      requires :id, type: Integer, desc: 'The ID of a project'
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      before do
        authorize_packages_feature!(unauthorized_user_project!)
      end

      desc 'Composer packages endpoint for registering packages'

      namespace ':id/packages/composer' do
        route_setting :authentication, job_token_allowed: true

        params do
          optional :branch, type: String, desc: 'The name of the branch'
          optional :tag, type: String, desc: 'The name of the tag'
          exactly_one_of :tag, :branch
        end

        post do
          authorize_create_package!(authorized_user_project)

          if params[:branch].present?
            params[:branch] = find_branch!(params[:branch])
          elsif params[:tag].present?
            params[:tag] = find_tag!(params[:tag])
          else
            bad_request!
          end

          track_event('register_package')

          ::Packages::Composer::CreatePackageService
            .new(authorized_user_project, current_user, declared_params)
            .execute

          created!
        end

        params do
          requires :sha, type: String, desc: 'Shasum of current json'
          requires :package_name, type: String, file_path: true, desc: 'The Composer package name'
        end

        get 'archives/*package_name' do
          metadata = unauthorized_user_project
            .packages
            .composer
            .with_name(params[:package_name])
            .with_composer_target(params[:sha])
            .first
            &.composer_metadatum

          not_found! unless metadata

          send_git_archive unauthorized_user_project.repository, ref: metadata.target_sha, format: 'zip', append_sha: true
        end
      end
    end
  end
end
