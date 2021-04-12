# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DropPipelineService do
  let(:failure_reason) { :runner_unsupported } # TODO: change this to :user_blocked

  describe '#execute_async_for_all' do
    let(:user) { create(:user) }
    let!(:cancelable_pipeline) { create(:ci_pipeline, :running, user: user) }
    let!(:success_pipeline) { create(:ci_pipeline, :success, user: user) }

    subject { described_class.new.execute_async_for_all(user.pipelines, failure_reason) }

    it 'calls Ci::DropPipelineWorker for each cancelable pipeline' do
      expect(Ci::DropPipelineWorker).to receive(:perform_async).with(cancelable_pipeline.id, failure_reason)
      expect(Ci::DropPipelineWorker).not_to receive(:perform_async).with(success_pipeline.id, failure_reason)

      subject
    end
  end

  describe '#execute' do
    let_it_be(:project) { create(:project) }

    let(:pipeline) { create(:ci_pipeline, project: project) }
    let!(:running_build) { create(:ci_build, :running, pipeline: pipeline) }
    let!(:success_build) { create(:ci_build, :success, pipeline: pipeline) }

    subject { described_class.new.execute(pipeline.id, failure_reason) }

    def drop_pipeline!
      described_class.new.execute(pipeline, failure_reason)
    end

    it 'drops each cancelable build in the pipeline', :aggregate_failures do
      drop_pipeline!

      expect(running_build.reload).to be_failed
      expect(running_build.failure_reason).to eq(failure_reason.to_s)

      expect(success_build.reload).to be_success
    end

    it 'avoids N+1 queries when reading data' do
      control_count = ActiveRecord::QueryRecorder.new { drop_pipeline! }.count
      writes_per_build = 2
      expected_reads_count = control_count - writes_per_build

      create_list(:ci_build, 5, :running, pipeline: pipeline)

      expect { drop_pipeline! }.not_to exceed_query_limit(expected_reads_count + (5 * writes_per_build))
    end
  end
end
