# frozen_string_literal: true

module API
  class FeatureFlags < Grape::API
    include PaginationParams

    FEATURE_FLAG_ENDPOINT_REQUIREMETS = API::NAMESPACE_OR_PROJECT_REQUIREMENTS
        .merge(name: API::NO_SLASH_URL_PART_REGEX)

    before { authorize_read_feature_flags! }

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get all feature flags of a project' do
        detail 'This feature was introduced in GitLab 12.4.'
        success EE::API::Entities::FeatureFlag
      end
      params do
        optional :scope, type: String, desc: 'The scope', values: %w[enabled disabled]
        use :pagination
      end
      get ':id/feature_flags' do
        feature_flags = ::FeatureFlagsFinder
          .new(user_project, current_user, scope: params[:scope])
          .execute(preload: true)

        present paginate(feature_flags), with: EE::API::Entities::FeatureFlag
      end

      desc 'Get a feature flag of a project' do
        detail 'This feature was introduced in GitLab 12.4.'
        success EE::API::Entities::FeatureFlag
      end
      params do
        requires :name, type: String, desc: 'The name of the feature flag'
      end
      get ':id/feature_flags/:name', requirements: FEATURE_FLAG_ENDPOINT_REQUIREMETS do
        present feature_flag, with: EE::API::Entities::FeatureFlag
      end

      desc 'Create a new feature flag' do
        detail 'This feature was introduced in GitLab 12.4.'
        success EE::API::Entities::FeatureFlag
      end
      params do
        requires :name,         type: String
        optional :description,  type: String
        optional :scopes_attributes, type: Array do
          requires :environment_scope, type: String
          requires :active, type: Boolean
          requires :strategies, type: JSON
        end
      end
      post ':id/feature_flags' do
        authorize_create_feature_flag!

        result = ::FeatureFlags::CreateService
          .new(user_project, current_user, declared_params(include_missing: false))
          .execute

        if result[:status] == :success
          present result[:feature_flag], with: EE::API::Entities::FeatureFlag
        else
          render_api_error!(result[:message], result[:http_status])
        end
      end

      desc 'Update a feature flag' do
        detail 'This feature was introduced in GitLab 12.4.'
        success EE::API::Entities::FeatureFlag
      end
      params do
        optional :new_name,     type: String
        optional :description,  type: String
        at_least_one_of :new_name, :description
      end
      put ':id/feature_flags/:name', requirements: FEATURE_FLAG_ENDPOINT_REQUIREMETS do
        authorize_update_feature_flag!

        result = ::FeatureFlags::UpdateService
          .new(user_project, current_user, declared_params(include_missing: false))
          .execute(feature_flag)

        if result[:status] == :success
          present result[:feature_flag], with: EE::API::Entities::FeatureFlag
        else
          render_api_error!(result[:message], result[:http_status])
        end
      end

      desc 'Delete a feature flag' do
        detail 'This feature was introduced in GitLab 12.4.'
        success EE::API::Entities::FeatureFlag
      end
      params do
        optional :name,         type: String, desc: 'The name of the feature flag'
      end
      delete ':id/feature_flags/:name', requirements: FEATURE_FLAG_ENDPOINT_REQUIREMETS do
        authorize_destroy_feature_flag!

        result = ::FeatureFlags::DestroyService
          .new(user_project, current_user, declared_params(include_missing: false))
          .execute(feature_flag)

        if result[:status] == :success
          present result[:feature_flag], with: EE::API::Entities::FeatureFlag
        else
          render_api_error!(result[:message], result[:http_status])
        end
      end
    end

    helpers do
      def authorize_read_feature_flags!
        authorize! :read_feature_flag, user_project
      end

      def authorize_read_feature_flag!
        authorize! :read_feature_flag, feature_flag
      end

      def authorize_create_feature_flag!
        authorize! :create_feature_flag, user_project
      end

      def authorize_update_feature_flag!
        authorize! :update_feature_flag, feature_flag
      end

      def authorize_destroy_feature_flag!
        authorize! :destroy_feature_flag, feature_flag
      end

      def feature_flag
        @feature_flag ||= user_project.operations_feature_flags.find_by_name!(params[:name])
      end
    end
  end
end
