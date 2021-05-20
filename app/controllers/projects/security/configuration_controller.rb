# frozen_string_literal: true

module Projects
  module Security
    class ConfigurationController < Projects::ApplicationController
      include SecurityAndCompliancePermissions

      feature_category :static_application_security_testing

      before_action only: [:show] do
        push_frontend_feature_flag(:security_configuration_redesign, project, default_enabled: :yaml)
      end

      def show
        render_403 unless can?(current_user, :read_security_configuration, project)

        @configuration = ::Projects::Security::ConfigurationPresenter.new(project,
                                                                          auto_fix_permission: auto_fix_authorized?,
                                                                          current_user: current_user)
        respond_to do |format|
          format.html
          format.json do
            render status: :ok, json: @configuration.to_h
          end
        end
      end
    end
  end
end

Projects::Security::ConfigurationController.prepend_mod_with('Projects::Security::ConfigurationController')
