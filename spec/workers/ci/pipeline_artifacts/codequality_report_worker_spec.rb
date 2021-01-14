# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ci::PipelineArtifacts::CodequalityReportWorker do
  describe '#perform' do
    subject { described_class.new.perform(pipeline_id) }

    context 'when pipeline exists' do
      let(:pipeline) { create(:ci_pipeline) }
      let(:pipeline_id) { pipeline.id }

      it 'calls pipeline codequality report service' do
        expect_next_instance_of(::Ci::PipelineArtifacts::CodequalityReportService) do |create_artifact_service|
          expect(create_artifact_service).to receive(:execute)
        end

        subject
      end
    end

    context 'when pipeline does not exist' do
      let(:pipeline_id) { non_existing_record_id }

      it 'does not call pipeline codequality report service' do
        expect(Ci::PipelineArtifacts::CodequalityReportService).not_to receive(:execute)

        subject
      end
    end
  end
end
