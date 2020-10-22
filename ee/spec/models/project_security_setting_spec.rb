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
end
