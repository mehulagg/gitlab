# frozen_string_literal: true

module API
  class GroupProtectedEnvironments < ::API::Base
    include PaginationParams

    before do
      authorize_admin_group

      unless Feature.enabled?(:group_level_protected_environments_alpha, user_group, default_enabled: :yaml)
        not_found!
      end
    end

    feature_category :continuous_delivery

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end

    resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc "Get a group's protected environments" do
        detail 'This feature was introduced in GitLab 13.12.'
        success ::EE::API::Entities::GroupProtectedEnvironment
      end
      params do
        use :pagination
      end
      get ':id/protected_environments' do
        protected_environments = user_group.protected_environments.sorted_by_tier

        present paginate(protected_environments), with: ::EE::API::Entities::GroupProtectedEnvironment
      end

      desc 'Get a single protected environment' do
        detail 'This feature was introduced in GitLab 13.12.'
        success ::EE::API::Entities::GroupProtectedEnvironment
      end
      params do
        requires :tier, type: String, desc: 'The tier of the protected environment'
      end
      get ':id/protected_environments/:tier' do
        present protected_environment, with: ::EE::API::Entities::GroupProtectedEnvironment
      end

      desc 'Protect a single environment' do
        detail 'This feature was introduced in GitLab 13.12.'
        success ::EE::API::Entities::GroupProtectedEnvironment
      end
      params do
        requires :tier, type: String, desc: 'The tier of the protected environment'

        requires :deploy_access_levels_attributes, as: :deploy_access_levels, type: Array, desc: 'An array of users/groups allowed to deploy environment' do
          optional :access_level, type: Integer, values: ::ProtectedEnvironment::DeployAccessLevel::ALLOWED_ACCESS_LEVELS
          optional :user_id, type: Integer
          optional :group_id, type: Integer
        end
      end
      post ':id/protected_environments' do
        declared_params = declared_params(include_missing: false)
        protected_environment = user_group.protected_environments.create(declared_params)

        if protected_environment.persisted?
          present protected_environment, with: ::EE::API::Entities::GroupProtectedEnvironment
        else
          render_api_error!(protected_environment.errors.full_messages, 422)
        end
      end

      desc 'Unprotect a single environment' do
        detail 'This feature was introduced in GitLab 13.12.'
      end
      params do
        requires :tier, type: String, desc: 'The tier of the protected environment'
      end
      delete ':id/protected_environments/:tier' do
        destroy_conditionally!(protected_environment)
      end
    end

    helpers do
      def protected_environment
        @protected_environment ||= user_group.protected_environments.find_by_tier!(params[:tier])
      end
    end
  end
end
