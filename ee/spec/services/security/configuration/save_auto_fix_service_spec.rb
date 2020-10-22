# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Configuration::SaveAutoFixService do
  describe '#execute' do
    let_it_be(:project) { create(:project) }

    subject(:service) { described_class.new(project, feature) }

    before do
      service.execute(enabled: false)
    end

    context 'with supported scanner type' do
      let(:feature) { 'dependency_scanning' }

      it 'changes setting' do
        expect(project.security_setting.auto_fix_dependency_scanning).to be_falsey
      end
    end

    context 'with all scanners' do
      let(:feature) { 'all' }

      it 'changes setting' do
        expect(project.security_setting.auto_fix_dependency_scanning).to be_falsey
        expect(project.security_setting.auto_fix_container_scanning).to be_falsey
      end
    end

    context 'with not supported scanner type' do
      let(:feature) { :dep_scan }

      before do
        project.create_security_setting
      end

      it 'does not change setting' do
        expect(project.security_setting.auto_fix_dependency_scanning).to be_truthy
      end
    end
  end
end
