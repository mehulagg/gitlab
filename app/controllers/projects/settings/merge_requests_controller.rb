# frozen_string_literal: true

module Projects
  module Settings
    class MergeRequestsController < Projects::ApplicationController
      layout 'project_settings'

      before_action :authorize_admin_project!

      feature_category :code_review

      def show
      end
    end
  end
end

Projects::Settings::MergeRequestsController.prepend_if_ee('::EE::Projects::Settings::MergeRequestsController')
