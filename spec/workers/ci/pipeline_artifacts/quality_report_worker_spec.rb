# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ci::PipelineArtifacts::QualityReportWorker do
  describe '#perform' do
    subject { described_class.new.perform(pipeline_id) }

    context 'when pipeline exists' do
      let(:pipeline) { create(:ci_pipeline) }
      let(:pipeline_id) { pipeline.id }

      it 'calls pipeline codequality report service' do
        expect_next_instance_of(::Ci::PipelineArtifacts::QualityReportService) do |quality_report_service|
          expect(quality_report_service).to receive(:execute)
        end

        subject
      end

      it_behaves_like 'an idempotent worker' do
        let(:job_args) { pipeline_id }

        it 'do not create the same artifact twice for a given pipeline' do
          expect { subject }.not_to change { pipeline.pipeline_artifacts.count }
        end
      end
    end

    context 'when pipeline does not exist' do
      let(:pipeline_id) { non_existing_record_id }

      it 'does not call pipeline codequality report service' do
        expect(Ci::PipelineArtifacts::QualityReportService).not_to receive(:execute)

        subject
      end
    end
  end
end
