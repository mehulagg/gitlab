# frozen_string_literal: true

module Projects
  module Settings
    class PackagesAndRegistriesController < Projects::ApplicationController
      layout 'project_settings'
      before_action :authorize_admin_project!
      before_action :verify_clean_up_policies!

      feature_category :package_registry

      def index
      end

      private

      def verify_clean_up_policies!
        render_404 unless Gitlab.config.registry.enabled && can?(current_user, :destroy_container_image, project)
      end
    end
  end
end
