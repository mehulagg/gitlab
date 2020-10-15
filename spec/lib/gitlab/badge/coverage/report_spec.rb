# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Badge::Coverage::Report do
  let(:project) { create(:project, :repository) }

  let(:successful_pipeline) do
    create(:ci_pipeline, :success, project: project, sha: project.commit.id, ref: 'master').tap do |pipeline|
      create(:ci_build, :success, pipeline: pipeline, name: 'coverage', coverage: 25)
    end
  end

  let(:successful_pipeline_with_two_coverages) do
    create(:ci_pipeline, :success, project: project, sha: project.commit.id, ref: 'master').tap do |pipeline|
      create(:ci_build, :success, pipeline: pipeline, name: 'early', coverage: 40)
      create(:ci_build, :success, pipeline: pipeline, name: 'coverage', coverage: 60)
    end
  end

  let(:failing_pipeline) do
    create(:ci_pipeline, :failed, project: project, sha: project.commit.id, ref: 'master').tap do |pipeline|
      create(:ci_build, :failed, pipeline: pipeline, name: 'coverage', coverage: 10)
    end
  end

  let(:job_name) { nil }

  let(:badge) do
    described_class.new(project, 'master', opts: { job: job_name })
  end

  describe '#entity' do
    it 'describes a coverage' do
      expect(badge.entity).to eq 'coverage'
    end
  end

  describe '#metadata' do
    it 'returns correct metadata' do
      expect(badge.metadata.image_url).to include 'coverage.svg'
    end
  end

  describe '#template' do
    it 'returns correct template' do
      expect(badge.template.key_text).to eq 'coverage'
    end
  end

  describe '#status' do
    context 'coverage job name is passed' do
      before do
        successful_pipeline
        successful_pipeline_with_two_coverages
        failing_pipeline
      end

      context 'and matches a passing job' do
        let(:job_name) { 'early' }

        it 'returns coverage from that job' do
          expect(badge.status).to eq(40)
        end
      end

      context 'and matches a failing job' do
        let(:job_name) { 'coverage' }

        it 'returns the coverage from the most recent passing job of that name' do
          expect(badge.status).to eq(60)
        end
      end

      context 'and does not match a job' do
        let(:job_name) { 'unknown' }

        it 'returns coverage of the most recent passing pipeline' do
          expect(badge.status).to be_nil
        end
      end
    end

    context 'coverage job name is not passed' do
      context 'with a successful pipeline' do
        before do
          successful_pipeline
          failing_pipeline
        end

        it 'returns coverage from the most recent successful pipeline' do
          expect(badge.status).to eq(successful_pipeline.coverage.to_f.round(2))
        end
      end

      context 'with only failing pipelines' do
        before do
          failing_pipeline
        end

        it 'returns nil' do
          expect(badge.status).to be_nil
        end
      end

      context 'with no pipelines' do
        it 'returns nil' do
          expect(badge.status).to be_nil
        end
      end
    end
  end
end
