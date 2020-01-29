# frozen_string_literal: true
module API
  class ComposerPackages < Grape::API
    COMPOSER_ENDPOINT_REQUIREMENTS = {
      package_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    before do
      require_packages_enabled!
      authenticate_non_get!
    end

    helpers ::API::Helpers::PackagesHelpers

    desc 'Composer packages endpoint at instance level' do
      detail 'This feature was introduced in GitLab 12.8'
    end
    route_setting :authentication, job_token_allowed: true
    get 'packages/composer/packages.json' do
      packages = ::Packages::ComposerPackagesFinder.new(current_user).execute
      presenter = ComposerPackagePresenter.new(packages)
      sha = Digest::SHA1.hexdigest(presenter.versions.to_json)

      presenter.packages_root(sha)
    end

    desc 'Composer registry endpoint at instance level for include/all${sha}.json' do
      detail 'This feature was introduced in GitLab 12.8'
    end
    params do
      requires :sha, type: String, desc: 'Shasum of current packages.json'
    end
    route_setting :authentication, job_token_allowed: true
    get 'packages/composer/include/all$*sha.json' do
      packages = ::Packages::ComposerPackagesFinder.new(current_user).execute
      presenter = ComposerPackagePresenter.new(packages)
      json = presenter.versions

      presenter.same_sha?(params[:sha]) ? json : (status 404)
    end

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :group, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Composer packages endpoint at group level' do
        detail 'This feature was introduced in GitLab 12.8'
      end
      route_setting :authentication, job_token_allowed: true
      get ':id/-/packages/composer/packages.json' do
        group = find_namespace(params[:id])
        packages = ::Packages::ComposerPackagesFinder.new(current_user, group).execute
        presenter = ComposerPackagePresenter.new(packages)
        sha = Digest::SHA1.hexdigest(presenter.versions.to_json)

        group ? presenter.packages_root(sha) : (status 404)
      end

      desc 'Composer packages endpoint at group level for include/all${sha}.json' do
        detail 'This feature was introduced in GitLab 12.8'
      end
      params do
        requires :sha, type: String, desc: 'Shasum of current packages.json'
      end
      route_setting :authentication, job_token_allowed: true
      get ':id/-/packages/composer/include/all$*sha.json', requirements: COMPOSER_ENDPOINT_REQUIREMENTS do
        group = find_namespace(params[:id])
        packages = ::Packages::ComposerPackagesFinder.new(current_user, group).execute
        presenter = ComposerPackagePresenter.new(packages)
        json = presenter.versions

        presenter.same_sha?(params[:sha]) && group ? json : (status 404)
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      before do
        authorize_packages_feature!(user_project)
      end

      desc 'Download the Composer archive, can be zip or tar' do
        detail 'This feature was introduced in GitLab 12.8'
      end
      params do
        requires :package_name, type: String, desc: 'Package name'
        requires :file_name, type: String, desc: 'Package file name'
      end
      route_setting :authentication, job_token_allowed: true
      get ':id/packages/composer/*package_name/-/*file_name', format: false do
        package = Project.find_by_full_path(params[:id]).packages.composer
                      .by_name_and_file_name(params[:package_name], params[:file_name])

        authorize_read_package!(user_project)

        package_file = ::Packages::PackageFileFinder
                           .new(package, params[:file_name]).execute!

        present_carrierwave_file!(package_file.file)
      end

      desc 'Upload and create Composer package' do
        detail 'This feature was introduced in GitLab 12.8'
      end
      params do
        requires :package_name, type: String, desc: 'Package name'
      end
      route_setting :authentication, job_token_allowed: true
      put ':id/packages/composer/:package_name', requirements: COMPOSER_ENDPOINT_REQUIREMENTS do
        authorize_create_package!

        body = request.body.read.force_encoding(Encoding::UTF_8)

        ::Packages::Composer::CreatePackageService.new(user_project, current_user, body).execute
      end
    end
  end
end
