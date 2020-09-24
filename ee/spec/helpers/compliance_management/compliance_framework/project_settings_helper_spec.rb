# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::ProjectSettingsHelper do
  let_it_be(:compliance_framework) { create(:compliance_framework, id: 1, name: 'test1', description: 'testdesc1') }
  let_it_be(:compliance_framework_2) { create(:compliance_framework, id: 2, name: 'test2', description: 'testdesc2') }

  describe '#compliance_framework_options' do
    it 'has all the options' do
      expect(helper.compliance_framework_options).to contain_exactly(
        ['test1 - testdesc1', 1],
        ['test2 - testdesc2', 2]
      )
    end
  end

  describe '#compliance_framework_checkboxes' do
    it 'has all the checkboxes' do
      expect(helper.compliance_framework_checkboxes).to contain_exactly(
        [1, 'test1'],
        [2, 'test2']
      )
    end
  end

  describe '#compliance_framework_tooltip' do
    subject { compliance_framework_tooltip(compliance_framework) }

    it { is_expected.to eq('This project is regulated by test1.') }
  end
end
