# frozen_string_literal: true

module ComplianceManagement
  module ComplianceFramework
    module GroupSettingsHelper
      def show_compliance_frameworks?
        License.feature_available?(:custom_compliance_frameworks) && Feature.enabled?(:ff_custom_compliance_frameworks, @group)
      end

      def pipeline_configuration_full_path_enabled?
        License.feature_available?(:evaluate_group_level_compliance_pipeline) && Feature.enabled?(:ff_custom_compliance_frameworks, @group)
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
          pipeline_configuration_full_path_enabled: pipeline_configuration_full_path_enabled?.to_s,
        }
      end
    end
  end
end
