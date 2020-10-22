# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::TriggerDownstreamSubscriptionService do
  describe '#execute' do
    subject(:execute) { described_class.new(pipeline.project, pipeline.user).execute(pipeline) }

    let(:upstream_project) { create(:project, :public) }
    let(:pipeline) { create(:ci_pipeline, project: upstream_project, user: create(:user)) }

    before do
      stub_ci_pipeline_yaml_file(YAML.dump(job_name: { script: 'echo 1' }))
    end

    context 'when pipeline project has downstream projects' do
      before do
        downstream_project = create(:project, :repository, upstream_projects: [upstream_project])
        downstream_project.add_developer(pipeline.user)
      end

      it 'creates a pipeline' do
        expect { execute }.to change { ::Ci::Pipeline.count }.from(1).to(2)
      end

      it 'associates the downstream pipeline with the upstream project' do
        expect { execute }.to change { pipeline.project.sourced_pipelines.count }.from(0).to(1)
      end
    end

    context 'when pipeline project does not have downstream projects' do
      it 'does not call the create pipeline service' do
        expect(::Ci::CreatePipelineService).not_to receive(:new)

        execute
      end
    end
  end
end
