# frozen_string_literal: true

module Groups
  module Security
    class VulnerabilitiesController < Groups::ApplicationController
      layout 'group'

      before_action do
        push_frontend_feature_flag(:custom_security_scanners, current_user)
        push_frontend_feature_flag(:vulnerability_management_survey, type: :ops)
      end

      feature_category :vulnerability_management

      def index
        render :unavailable unless dashboard_available?
      end

      private

      def dashboard_available?
        can?(current_user, :read_group_security_dashboard, group)
      end
    end
  end
end
