# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectSecuritySetting do
  describe 'associations' do
    subject { create(:project_security_setting) }

    it { is_expected.to belong_to(:project) }
  end

  describe '.safe_find_or_create_for' do
    subject { described_class.safe_find_or_create_for(project) }

    let_it_be(:project) { create :project }

    context 'without existing setting' do
      it 'creates a new entry' do
        expect { subject }.to change { ProjectSecuritySetting.count }.by(1)
        expect(subject).to be_a_kind_of(ProjectSecuritySetting)
      end
    end

    context 'with existing setting' do
      before do
        project.create_security_setting
      end

      it 'reuses existing entry' do
        expect { subject }.not_to change { ProjectSecuritySetting.count }
        expect(subject).to be_a_kind_of(ProjectSecuritySetting)
      end
    end
  end

  describe '#auto_fix_enabled?' do
    subject { setting.auto_fix_enabled? }

    let_it_be(:setting) { build(:project_security_setting) }

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
