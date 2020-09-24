# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::ExpirePipelineCacheService do
  let(:pipeline) { create(:ci_empty_pipeline) }

  subject { described_class.new }

  describe '#perform' do
    context 'when pipeline is triggered by other pipeline' do
      let(:source) { create(:ci_sources_pipeline, pipeline: pipeline) }

      it 'updates the cache of dependent pipeline' do
        dependent_pipeline_path = "/#{source.source_project.full_path}/-/pipelines/#{source.source_pipeline.id}.json"

        allow_any_instance_of(Gitlab::EtagCaching::Store).to receive(:touch)
        expect_any_instance_of(Gitlab::EtagCaching::Store).to receive(:touch).with(dependent_pipeline_path)

        subject.execute(pipeline)
      end
    end

    context 'when pipeline triggered other pipeline' do
      let(:build) { create(:ci_build, pipeline: pipeline) }
      let(:source) { create(:ci_sources_pipeline, source_job: build) }

      it 'updates the cache of dependent pipeline' do
        dependent_pipeline_path = "/#{source.project.full_path}/-/pipelines/#{source.pipeline.id}.json"

        allow_any_instance_of(Gitlab::EtagCaching::Store).to receive(:touch)
        expect_any_instance_of(Gitlab::EtagCaching::Store).to receive(:touch).with(dependent_pipeline_path)

        subject.execute(pipeline)
      end
    end
  end
end
