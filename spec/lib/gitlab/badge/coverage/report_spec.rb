# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Badge::Coverage::Report do
  let(:project) { double('project') }

  let_it_be(:successful_pipeline) do
    create(:ci_pipeline, :success)
  end

  let(:badge) do
    described_class.new(project, 'master', opts: { job: job_name }).tap do |new_badge|
      allow(new_badge).to receive(:pipeline).and_return(successful_pipeline)
    end
  end

  let(:job_name) { nil }
  let(:builds) { [] }

  before do
    allow(successful_pipeline).to receive(:builds).and_return(Ci::Build.where(id: builds.map(&:id)))
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

  shared_examples 'unknown coverage report' do
    context 'particular job specified' do
      let(:job_name) { '' }

      it 'returns nil' do
        expect(badge.status).to be_nil
      end
    end

    context 'particular job not specified' do
      let(:job_name) { nil }

      it 'returns nil' do
        expect(badge.status).to be_nil
      end
    end
  end

  context 'when latest successful pipeline exists' do
    let(:builds) do
      [
        create(:ci_build, :success, pipeline: pipeline, name: 'first', coverage: 40),
        create(:ci_build, :success, pipeline: pipeline, coverage: 60)
      ]
    end

    context 'when particular job specified' do
      let(:job_name) { 'first' }

      it 'returns coverage for the particular job' do
        expect(badge.status).to eq 40
      end
    end

    context 'when particular job not specified' do
      let(:job_name) { '' }

      it 'returns arithemetic mean for the pipeline' do
        expect(badge.status).to eq 50
      end
    end
  end

  context 'pipeline does not exist' do
    it_behaves_like 'unknown coverage report'
  end
end
