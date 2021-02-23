# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    def compliance_pipeline_configuration_available?
      return true unless params[:pipeline_configuration_full_path].present?

      can? current_user, :manage_group_level_compliance_pipeline_config, framework
    end
  end
end
