# frozen_string_literal: true

module API
  class PackagePushes < ::API::Base
    feature_category :package_registry

    resource :package_pushes, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get package file from single push' do
        detail 'This feature is WIP'
      end
      params do
        requires :sha, type: String, desc: 'Sha of package push'
      end
      route_setting :authentication, job_token_allowed: true
      get ':sha' do
        push = ::Packages::Push.with_sha(params[:sha])

        not_found!("Package push") unless can?(current_user, :read_package, push&.project)

        present_carrierwave_file!(push.package_file.file, supports_direct_download: false)
      end
    end
  end
end
