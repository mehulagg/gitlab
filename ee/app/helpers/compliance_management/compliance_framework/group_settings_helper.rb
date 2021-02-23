# frozen_string_literal: true

module ComplianceManagement
  module ComplianceFramework
    module GroupSettingsHelper
      def show_compliance_frameworks?
        current_user.can?(:admin_compliance_framework, @group)
      end

      def compliance_frameworks_list_data
        {
          empty_state_svg_path: image_path('illustrations/welcome/ee_trial.svg'),
          group_path: @group.full_path
        }
      end
    end
  end
end
