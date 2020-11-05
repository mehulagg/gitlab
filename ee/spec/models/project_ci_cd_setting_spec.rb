# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectCiCdSetting do
  before do
    stub_feature_flags(disable_merge_trains: false)
  end

  describe '#merge_pipelines_enabled?' do
    subject { project.merge_pipelines_enabled? }

    let(:project) { create(:project) }
    let(:merge_pipelines_enabled) { true }

    before do
      project.merge_pipelines_enabled = merge_pipelines_enabled
    end

    context 'when Merge pipelines (EEP) is available' do
      before do
        stub_licensed_features(merge_pipelines: true)
      end

      it { is_expected.to be_truthy }

      context 'when project setting is disabled' do
        let(:merge_pipelines_enabled) { false }

        it { is_expected.to be_falsy }
      end
    end

    context 'when Merge pipelines (EEP) is unavailable' do
      before do
        stub_licensed_features(merge_pipelines: false)
      end

      it { is_expected.to be_falsy }

      context 'when project setting is disabled' do
        let(:merge_pipelines_enabled) { false }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#merge_trains_enabled?' do
    subject { project.merge_trains_enabled? }

    let(:project) { create(:project) }

    context 'when Merge trains (EEP) is available' do
      before do
        stub_licensed_features(merge_pipelines: true, merge_trains: true)
        project.merge_pipelines_enabled = true
      end

      it { is_expected.to be_truthy }
    end

    context 'when Merge trains (EEP) is unavailable' do
      before do
        stub_licensed_features(merge_trains: false)
      end

      it { is_expected.to be_falsy }
    end
  end

  describe '#auto_rollback_enabled?' do
    using RSpec::Parameterized::TableSyntax

    let(:project) { create(:project) }

    where(:license_feature, :feature_flag, :actual_setting) do
      true  | true  | true
      false | true  | true
      true  | false | true
      false | false | true
      true  | true  | false
      false | true  | false
      true  | false | false
      false | false | false
    end

    with_them do
      before do
        stub_licensed_features(auto_rollback: license_feature)
        stub_feature_flags(cd_auto_rollback: feature_flag)
        project.auto_rollback_enabled = actual_setting
      end

      it 'is only enabled if set and both the license and the feature flag allows' do
        expect(project.auto_rollback_enabled?).to be(actual_setting && license_feature && feature_flag)
      end
    end
  end

  describe '#merge_pipelines_were_disabled?' do
    subject { project.merge_pipelines_were_disabled? }

    let(:project) { create(:project) }

    before do
      stub_licensed_features(merge_pipelines: true, merge_trains: true)
    end

    context 'when merge pipelines option was enabled' do
      before do
        project.update(merge_pipelines_enabled: true)
      end

      context 'when merge pipelines option is disabled' do
        before do
          project.update(merge_pipelines_enabled: false)
        end

        it { is_expected.to be true }
      end

      context 'when merge pipelines option is intact' do
        it { is_expected.to be false }
      end
    end

    context 'when merge pipelines option was disabled' do
      before do
        project.update(merge_pipelines_enabled: false)
      end

      context 'when merge pipelines option is disabled' do
        before do
          project.update(merge_pipelines_enabled: true)
        end

        it { is_expected.to be false }
      end

      context 'when merge pipelines option is intact' do
        it { is_expected.to be false }
      end
    end
  end
end
