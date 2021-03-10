# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::AbortPipelinesService do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }

  describe '#execute' do
    let_it_be(:pipeline) { create(:ci_pipeline, :running, project: project) }
    let_it_be(:build) { create(:ci_build, :running, pipeline: pipeline) }

    context 'with project pipelines' do
      it 'cancels all running pipelines and related jobs' do
        result = described_class.new.execute(project.all_pipelines)

        expect(result).to be_success
        expect(pipeline.reload).to be_canceled
        expect(build.reload).to be_canceled
      end

      it 'avoids N+1 queries' do
        project_pipelines = project.all_pipelines
        control_count = ActiveRecord::QueryRecorder.new { described_class.new.execute(project_pipelines) }.count

        pipelines = create_list(:ci_pipeline, 5, :running, project: project)
        create_list(:ci_build, 5, :running, pipeline: pipelines.first)

        expect { described_class.new.execute(project_pipelines) }.not_to exceed_query_limit(control_count)
      end
    end

    context 'with user pipelines' do
      let_it_be(:cancelable_pipeline) { create(:ci_pipeline, :running, project: project, user: user) }
      let_it_be(:manual_pipeline) { create(:ci_pipeline, status: :manual, project: project, user: user) } # not cancelable
      let_it_be(:unrelated_pipeline) { create(:ci_pipeline, :running, project: project, user: create(:user)) } # not this user's pipeline
      let_it_be(:build) { create(:ci_build, :running, pipeline: cancelable_pipeline) }

      it 'cancels all running pipelines and related jobs' do
        result = described_class.new.execute(user.pipelines)

        expect(result).to be_success
        expect(cancelable_pipeline.reload).to be_canceled
        expect(manual_pipeline.reload).not_to be_canceled
        expect(unrelated_pipeline.reload).not_to be_canceled
        expect(build.reload).to be_canceled
      end

      it 'avoids N+1 queries' do
        user_pipelines = user.pipelines
        control_count = ActiveRecord::QueryRecorder.new { described_class.new.execute(user_pipelines) }.count

        pipelines = create_list(:ci_pipeline, 5, :running, project: project, user: user)
        create_list(:ci_build, 5, :running, pipeline: pipelines.first)

        expect { described_class.new.execute(user_pipelines) }.not_to exceed_query_limit(control_count)
      end
    end
  end
end
