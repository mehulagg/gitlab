# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::StagePresenter do
  let(:stage) { create(:ci_stage) }
  let(:presenter) { described_class.new(stage) }

  let!(:build) { create(:ci_build, :tags, :artifacts, pipeline: stage.pipeline, stage: stage.name) }
  let!(:retried_build) { create(:ci_build, :tags, :artifacts, :retried, pipeline: stage.pipeline, stage: stage.name) }

  before do
    create(:generic_commit_status, pipeline: stage.pipeline, stage: stage.name)
  end

  shared_examples 'preloaded associations for CI status' do
    it 'preloads project' do
      expect(subject.association(:project)).to be_loaded
    end

    it 'preloads build pipeline' do
      expect(subject.association(:pipeline)).to be_loaded
    end

    it 'preloads build tags' do
      expect(subject.association(:tags)).to be_loaded
    end

    it 'preloads build artifacts archive' do
      expect(subject.association(:job_artifacts_archive)).to be_loaded
    end

    it 'preloads build artifacts metadata' do
      expect(subject.association(:metadata)).to be_loaded
    end
  end

  describe '#latest_ordered_statuses' do
    subject { presenter.latest_ordered_statuses.second }

    it_behaves_like 'preloaded associations for CI status'
  end

  describe '#retried_ordered_statuses' do
    subject { presenter.retried_ordered_statuses.first }

    it_behaves_like 'preloaded associations for CI status'
  end
end
