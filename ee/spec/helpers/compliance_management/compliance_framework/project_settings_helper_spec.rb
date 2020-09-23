# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::ProjectSettingsHelper do
  describe '#compliance_framework_options' do
    it 'has all the options' do
      expect(helper.compliance_framework_options).to contain_exactly(
        ['GDPR - General Data Protection Regulation', :gdpr],
        ['HIPAA - Health Insurance Portability and Accountability Act', :hipaa],
        ['PCI-DSS - Payment Card Industry-Data Security Standard', :pci_dss],
        ['SOC 2 - Service Organization Control 2', :soc_2],
        ['SOX - Sarbanes-Oxley', :sox]
      )
    end
  end

  describe '#compliance_framework_checkboxes' do
    it 'has all the checkboxes' do
      expect(helper.compliance_framework_checkboxes).to contain_exactly(
        [1, 'GDPR'],
        [2, 'HIPAA'],
        [3, 'PCI-DSS'],
        [4, 'SOC 2'],
        [5, 'SOX']
      )
    end
  end

  describe '#compliance_framework_description' do
    using RSpec::Parameterized::TableSyntax

    where(:framework, :description) do
      :gdpr | 'GDPR - General Data Protection Regulation'
      :hipaa | 'HIPAA - Health Insurance Portability and Accountability Act'
      :pci_dss | 'PCI-DSS - Payment Card Industry-Data Security Standard'
      :soc_2 | 'SOC 2 - Service Organization Control 2'
      :sox | 'SOX - Sarbanes-Oxley'
    end

    with_them do
      it { expect(helper.compliance_framework_description(framework)).to eq(description) }
    end
  end

  describe '#compliance_framework_title' do
    using RSpec::Parameterized::TableSyntax

    where(:framework, :title) do
      :gdpr | 'GDPR'
      :hipaa | 'HIPAA'
      :pci_dss | 'PCI-DSS'
      :soc_2 | 'SOC 2'
      :sox | 'SOX'
    end

    with_them do
      it { expect(helper.compliance_framework_title(framework)).to eq(title) }
    end
  end

  describe '#compliance_framework_color' do
    using RSpec::Parameterized::TableSyntax

    where(:framework, :color) do
      :gdpr | 'gl-bg-green-500'
      :hipaa | 'gl-bg-blue-500'
      :pci_dss | 'gl-bg-theme-indigo-500'
      :soc_2 | 'gl-bg-red-500'
      :sox | 'gl-bg-orange-500'
    end

    with_them do
      it { expect(helper.compliance_framework_color(framework)).to eq(color) }
    end
  end

  describe '#compliance_framework_tooltip' do
    using RSpec::Parameterized::TableSyntax

    where(:framework, :tooltip) do
      :gdpr | 'This project is regulated by GDPR.'
      :hipaa | 'This project is regulated by HIPAA.'
      :pci_dss | 'This project is regulated by PCI-DSS.'
      :soc_2 | 'This project is regulated by SOC 2.'
      :sox | 'This project is regulated by SOX.'
    end

    with_them do
      it { expect(helper.compliance_framework_tooltip(framework)).to eq(tooltip) }
    end
  end
end
