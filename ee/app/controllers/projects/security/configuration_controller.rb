# frozen_string_literal: true

module Projects
  module Security
    class ConfigurationController < Projects::ApplicationController
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

      before_action only: [:show] do
        push_frontend_feature_flag(:security_auto_fix, project, default_enabled: false)
        push_frontend_feature_flag(:sast_configuration_ui, project, default_enabled: true)
        push_frontend_feature_flag(:api_fuzzing_configuration_ui, project, default_enabled: :yaml)
      end

      before_action only: [:auto_fix] do
        check_feature_flag!
        authorize_modify_auto_fix_setting!
      end

      feature_category :static_application_security_testing

      def show
        @configuration = ConfigurationPresenter.new(project,
                                                    auto_fix_permission: auto_fix_authorized?,
                                                    current_user: current_user)
        respond_to do |format|
          format.html
          format.json do
            render status: :ok, json: @configuration.to_h
          end
        end
      end

      def auto_fix
        service = ::Security::Configuration::SaveAutoFixService.new(project, auto_fix_params[:feature])

        return respond_422 unless service.execute(enabled: auto_fix_params[:enabled])

        render status: :ok, json: auto_fix_settings
      end

      private

      def auto_fix_authorized?
        can?(current_user, :modify_auto_fix_setting, project)
      end

      def auto_fix_params
        return @auto_fix_params if @auto_fix_params

        @auto_fix_params = params.permit(:feature, :enabled)

        feature = @auto_fix_params[:feature]
        @auto_fix_params[:feature] = feature.blank? ? 'all' : feature.to_s

        @auto_fix_params
      end

      def check_auto_fix_permissions!
        render_403 unless auto_fix_authorized?
      end

      def check_feature_flag!
        render_404 if Feature.disabled?(:security_auto_fix, project)
      end

      def auto_fix_settings
        setting = project.security_setting

        {
          dependency_scanning: setting.auto_fix_dependency_scanning,
          container_scanning: setting.auto_fix_container_scanning
        }
      end
    end
  end
end
