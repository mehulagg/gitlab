# frozen_string_literal: true

require_dependency 'compliance_management/compliance_framework'

module ComplianceManagement
  module ComplianceFramework
    module ProjectSettingsHelper
      def compliance_framework_options
        ::ComplianceManagement::Framework.all.map { |framework| [framework.display_name, framework.id] }
      end

      def compliance_framework_checkboxes
        ::ComplianceManagement::Framework.all.map do |framework|
          [framework.id, framework.name]
        end
      end

      def compliance_framework_tooltip(framework)
        s_("ComplianceFramework|This project is regulated by %{framework}." % { framework: framework.name })
      end
    end
  end
end
