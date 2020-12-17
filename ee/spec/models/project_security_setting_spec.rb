# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectSecuritySetting do
  describe 'associations' do
    subject { create(:project).security_setting }

    it { is_expected.to belong_to(:project) }
  end

  describe '#auto_fix_enabled?' do
    subject { setting.auto_fix_enabled? }

    let_it_be(:setting) { build(:project_security_setting) }

    context 'when licensed feature is enabled' do
      before do
        stub_licensed_features(vulnerability_auto_fix: true)
      end

      context 'when auto fix is enabled for available feature' do
        before do
          setting.auto_fix_container_scanning = false
          setting.auto_fix_dependency_scanning = true
        end

        it 'marks auto_fix as enabled' do
          is_expected.to be_truthy
        end
      end

      context 'when a auto_fix setting is disabled for available features' do
        before do
          setting.auto_fix_container_scanning = false
          setting.auto_fix_dependency_scanning = false
          setting.auto_fix_sast = false
        end

        it 'marks auto_fix as disabled' do
          is_expected.to be_falsey
        end
      end

      context 'when feature is disabled' do
        before do
          stub_feature_flags(security_auto_fix: false)
        end

        it 'marks auto_fix as disabled' do
          is_expected.to be_falsey
        end
      end
    end

    context 'when license feature is disabled' do
      before do
        stub_licensed_features(vulnerability_auto_fix: false)
      end

      it 'marks auto_fix as disabled' do
        is_expected.to be_falsey
      end
    end
  end

  describe '#auto_fix_enabled_types' do
    subject { setting.auto_fix_enabled_types }

    let_it_be(:setting) { build(:project_security_setting) }

    before do
      setting.auto_fix_container_scanning = false
      setting.auto_fix_dependency_scanning = true
      setting.auto_fix_sast = true
    end

    it 'return status only for available types' do
      is_expected.to eq([:dependency_scanning])
    end
  end
end
