# frozen_string_literal: true

module Projects
  module Security
    class SastConfigurationController < Projects::ApplicationController
      include SecurityAndCompliancePermissions
      include CreatesCommit
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

      before_action :authorize_edit_tree!, only: [:create]

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
    end
  end
end
