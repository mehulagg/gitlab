# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::AbortProjectPipelinesService do
  let_it_be(:project) { create(:project) }
  let_it_be(:pipeline) { create(:ci_pipeline, :running, project: project) }
  let_it_be(:build) { create(:ci_build, :running, pipeline: pipeline) }

  describe '#execute' do
    it 'cancels all running pipelines and related jobs' do
      result = described_class.new.execute(project)

      expect(result).to be_success
      expect(pipeline.reload).to be_canceled
      expect(build.reload).to be_canceled
    end

    it 'avoids N+1 queries' do
      control_count = ActiveRecord::QueryRecorder.new { described_class.new.execute(project) }.count

      pipelines = create_list(:ci_pipeline, 5, :running, project: project)
      create_list(:ci_build, 5, :running, pipeline: pipelines.first)

      expect { described_class.new.execute(project) }.not_to exceed_query_limit(control_count)
    end
  end
end
