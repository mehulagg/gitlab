# frozen_string_literal: true

module ComplianceManagement
  module ComplianceFramework
    module GroupSettingsHelper
      def show_compliance_frameworks?
        License.feature_available?(:custom_compliance_frameworks) && Feature.enabled?(:ff_custom_compliance_frameworks)
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
