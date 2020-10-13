# frozen_string_literal: true

require_dependency 'compliance_management/compliance_framework'

module ComplianceManagement
  module ComplianceFramework
    module ProjectSettingsHelper
      def compliance_framework_options
        option_values = compliance_framework_option_values
        ::ComplianceManagement::ComplianceFramework::FRAMEWORKS.map { |k, _v| [option_values.fetch(k), k] }
      end

      def compliance_framework_checkboxes
        ::ComplianceManagement::ComplianceFramework::FRAMEWORKS.map do |k, v|
          [v, compliance_framework_title_values.fetch(k)]
        end
      end

      def compliance_framework_description(framework)
        compliance_framework_option_values.fetch(framework.to_sym)
      end

      def compliance_framework_title(framework)
        compliance_framework_title_values.fetch(framework.to_sym)
      end

      def compliance_framework_color(framework)
        compliance_framework_color_values.fetch(framework.to_sym)
      end

      def compliance_framework_tooltip(framework)
        compliance_framework_tooltip_values.fetch(framework.to_sym)
      end

      private

      def compliance_framework_option_values
        {
          gdpr: s_('ComplianceFramework|GDPR - General Data Protection Regulation'),
          hipaa: s_('ComplianceFramework|HIPAA - Health Insurance Portability and Accountability Act'),
          pci_dss: s_('ComplianceFramework|PCI-DSS - Payment Card Industry-Data Security Standard'),
          soc_2: s_('ComplianceFramework|SOC 2 - Service Organization Control 2'),
          sox: s_('ComplianceFramework|SOX - Sarbanes-Oxley')
        }.freeze
      end

      def compliance_framework_title_values
        {
          gdpr: s_('ComplianceFramework|GDPR'),
          hipaa: s_('ComplianceFramework|HIPAA'),
          pci_dss: s_('ComplianceFramework|PCI-DSS'),
          soc_2: s_('ComplianceFramework|SOC 2'),
          sox: s_('ComplianceFramework|SOX')
        }.freeze
      end

      def compliance_framework_color_values
        {
          gdpr: 'gl-bg-green-500',
          hipaa: 'gl-bg-blue-500',
          pci_dss: 'gl-bg-theme-indigo-500',
          soc_2: 'gl-bg-red-500',
          sox: 'gl-bg-orange-500'
        }.freeze
      end

      def compliance_framework_tooltip_values
        @compliance_framework_tooltip_values ||=
          compliance_framework_title_values.transform_values { |v| get_compliance_framework_tooltip(v) }
      end

      def get_compliance_framework_tooltip(framework)
        s_("ComplianceFramework|This project is regulated by %{framework}." % { framework: framework })
      end
    end
  end
end
