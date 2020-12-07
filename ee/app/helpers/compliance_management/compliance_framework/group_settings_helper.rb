# frozen_string_literal: true

module ComplianceManagement
  module ComplianceFramework
    module GroupSettingsHelper
      def compliance_framework_labels_list_data
        {
          empty_state_svg_path: image_path('illustrations/labels.svg'),
          group_path: @group.full_path,
        }
      end
    end
  end
end
