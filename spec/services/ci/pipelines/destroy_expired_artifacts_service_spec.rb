# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Pipelines::DestroyExpiredArtifactsService do
  let(:service) { described_class.new }

  describe '.execute' do
    subject { service.execute }

    context 'when timeout happens' do
      before do
        stub_const('Ci::Pipelines::DestroyExpiredArtifactsService::LOOP_TIMEOUT', 1.second)
        allow(service).to receive(:destroy_artifacts_batch) { true }
      end

      it 'returns false and does not continue destroying' do
        is_expected.to be_falsy
      end
    end

    context 'when there are no artifacts' do
      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when loop reached loop limit' do
      before do
        stub_const('::Ci::Pipelines::DestroyExpiredArtifactsService::LOOP_LIMIT', 1)
        stub_const('::Ci::Pipelines::DestroyExpiredArtifactsService::BATCH_SIZE', 1)

        create_list(:ci_pipeline_artifact, 2, expire_at: 1.week.ago)
      end

      it 'destroys one artifact' do
        expect { subject }.to change { Ci::PipelineArtifact.count }.by(-1)
      end
    end

    context 'when there are artifacts more than batch sizes' do
      before do
        stub_const('Ci::Pipelines::DestroyExpiredArtifactsService::BATCH_SIZE', 1)

        create_list(:ci_pipeline_artifact, 2, expire_at: 1.week.ago)
      end

      it 'destroys all expired artifacts' do
        expect { subject }.to change { Ci::PipelineArtifact.count }.by(-2)
      end
    end

    context 'when artifacts are not expired' do
      before do
        create(:ci_pipeline_artifact, expire_at: 2.days.from_now)
      end

      it 'does not destroy pipeline artifacts' do
        expect { subject }.not_to change { Ci::PipelineArtifact.count }
      end
    end
  end

  describe '.destroy_artifacts_batch' do
    it 'returns a falsy value without artifacts' do
      expect(service.send(:destroy_artifacts_batch)).to be_falsy
    end
  end
end
