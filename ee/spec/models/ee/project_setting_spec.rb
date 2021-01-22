# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectSetting do
  it { is_expected.to belong_to(:push_rule) }

  describe '.has_vulnerabilities' do
    let_it_be(:setting_1) { create(:project_setting, :has_vulnerabilities) }
    let_it_be(:setting_2) { create(:project_setting) }

    subject { described_class.has_vulnerabilities }

    it { is_expected.to contain_exactly(setting_1) }
  end

  describe '#allow_editing_commits' do
    subject(:setting) { build(:project_setting) }

    context 'with a push rule' do
      context 'when reject unsigned commits is enabled' do
        it 'prevents editing commits' do
          setting.build_push_rule
          setting.push_rule.reject_unsigned_commits = true

          expect(setting).not_to be_valid
          expect(setting.errors[:allow_editing_commit_messages]).to be_present
        end
      end

      context 'when reject unsigned commits is disabled' do
        it 'allows editing commits' do
          setting.build_push_rule
          setting.push_rule.reject_unsigned_commits = false

          expect(setting).to be_valid
        end
      end
    end

    context 'without a push rule' do
      it 'allows editing commits' do
        expect(setting).to be_valid
      end
    end
  end
end
