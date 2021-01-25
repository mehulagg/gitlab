# frozen_string_literal: true

module Projects
  module Security
    class SastConfigurationController < Projects::ApplicationController
      include CreatesCommit

      alias_method :vulnerable, :project

      before_action :ensure_sast_configuration_enabled!, except: [:create]
      before_action :authorize_edit_tree!, only: [:create]
      before_action :ensure_read_security_configuration!

      feature_category :static_application_security_testing

      def show
      end

      def create
        result = ::Security::CiConfiguration::SastCreateService.new(project, current_user, params).execute

        if result[:status] == :success
          respond_to do |format|
            format.json { render json: { message: _("success"), filePath: result[:success_path] } }
          end
        else
          respond_to do |format|
            format.json { render json: { message: _("failed"), filePath: '' } }
          end
        end
      end

      private

      def ensure_sast_configuration_enabled!
        not_found unless ::Feature.enabled?(:sast_configuration_ui, project, default_enabled: true)
      end

      def ensure_read_security_configuration!
        render_403 unless can?(current_user, :read_security_configuration, project)
      end
    end
  end
end
