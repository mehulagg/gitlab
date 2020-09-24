# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::ProjectSecurityScannersInformation do
  let(:project) { create(:project, :repository) }
  let(:pipeline) { create(:ci_pipeline, project: project, sha: project.commit.id, ref: project.default_branch) }

  before do
    create(:ci_build, :success, :sast, pipeline: pipeline)
    create(:ci_build, :success, :dast, pipeline: pipeline)
    create(:ci_build, :success, :license_scanning, pipeline: pipeline)
    create(:ci_build, :pending, :secret_detection, pipeline: pipeline)
  end

  describe '#available_scanners' do
    before do
      allow(project).to receive(:feature_available?) { false }
      allow(project).to receive(:feature_available?).with(:sast) { true }
      allow(project).to receive(:feature_available?).with(:dast) { true }
    end

    it 'returns a list of all scanners available for the project' do
      expect(project.available_scanners).to match_array(%w(SAST DAST))
    end
  end

  describe '#enabled_scanners' do
    it 'returns a list of all scanners enabled for the project' do
      expect(project.enabled_scanners).to match_array(%w(SAST DAST SECRET_DETECTION))
    end
  end

  describe '#scanners_run_by_last_pipeline' do
    subject(:scanners_run_in_last_pipeline) { project.scanners_run_in_last_pipeline }

    context 'when pipeline has no build reports' do
      let!(:new_pipeline) { create(:ci_pipeline, project: project, sha: project.commit.id, ref: project.default_branch) }

      it { is_expected.to be_empty }
    end

    it 'returns a list of all scanners which were run successfully in the latest pipeline' do
      expect(scanners_run_in_last_pipeline).to match_array(%w(DAST SAST))
    end

    it 'does not include non-security scanners' do
      expect(scanners_run_in_last_pipeline).not_to include(%w(LICENSE_SCANNING))
    end
  end
end
