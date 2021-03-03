# frozen_string_literal: true

module ComplianceManagement
  module ComplianceFramework
    module GroupSettingsHelper
      def show_compliance_frameworks?
        can?(current_user, :admin_compliance_framework, @group)
      end

      def compliance_frameworks_list_data
        {
          empty_state_svg_path: image_path('illustrations/welcome/ee_trial.svg'),
          group_path: @group.full_path,
          add_framework_path: new_group_compliance_framework_path(@group)
        }
      end

      def compliance_frameworks_new_form_data
        {
          group_path: @group.full_path,
          group_edit_path: edit_group_path(@group, anchor: 'js-compliance-frameworks-settings'),
          graphql_field_name: ComplianceManagement::Framework.name,
          pipeline_configuration_full_path_enabled: pipeline_configuration_full_path_enabled?.to_s
        }
      end

      private

      def pipeline_configuration_full_path_enabled?
        can?(current_user, :admin_compliance_pipeline_configuration, @group)
      end
    end
  end
end
