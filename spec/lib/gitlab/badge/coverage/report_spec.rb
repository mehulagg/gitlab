# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Badge::Coverage::Report do
  let(:project) { build(:project) }

  let(:badge) do
    described_class.new(project, 'master', opts: { job: job_name })
  end

  let(:pipeline) { nil }
  let(:job_name) { nil }
  let(:builds) { [] }

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
    before do
      allow(badge).to receive(:pipeline).and_return(pipeline)
    end

    context 'with no pipeline' do
      it 'returns nil' do
        expect(badge.status).to be_nil
      end
    end

    context 'with no job specified' do
      let(:pipeline) { double('pipeline', coverage: 1) }

      it 'returns the pipeline coverage value' do
        expect(badge.status).to eq(1.00)
      end
    end

    context 'with an unmatching job name specified' do
      let(:job_name) { 'incorrect name' }
      let(:pipeline) { create(:ci_pipeline, :success, builds: builds) }

      let(:builds) do
        [
          create(:ci_build, :success, name: 'first', coverage: 40),
          create(:ci_build, :success, coverage: 60)
        ]
      end

      it 'returns nil' do
        expect(badge.status).to eq(nil)
      end
    end

    context 'with a matching job name specified' do
      let(:job_name) { 'first' }
      let(:pipeline) { create(:ci_pipeline, :success, builds: builds) }

      let(:builds) do
        [
          create(:ci_build, :success, name: 'first', coverage: 40),
          create(:ci_build, :success, coverage: 60)
        ]
      end

      it 'returns nil' do
        expect(badge.status).to eq(40.00)
      end
    end
  end
end
