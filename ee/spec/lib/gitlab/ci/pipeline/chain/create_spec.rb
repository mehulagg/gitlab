# frozen_string_literal: true

require 'spec_helper'

describe ::Gitlab::Ci::Pipeline::Chain::Create do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:pipeline) { build(:ci_pipeline, project: project, ref: 'master') }
  let(:command) { Gitlab::Ci::Pipeline::Chain::Command.new(project: project, current_user: user) }

  let(:step) { described_class.new(pipeline, command) }

  context 'when the pipeline is on the default branch' do
    context 'when the pipeline has upstream bridge jobs' do
      let(:upstream_project) { create(:project) }

      before do
        pipeline.stages.build(name: 'test', position: 0, project: project)
        pipeline.stages.first.bridges << build(:ci_upstream_bridge, upstream: upstream_project)
      end

      it 'populates the pipeline project upstream projects' do
        step.perform!

        expect(project.reload.upstream_projects).to be_one
        expect(project.reload.upstream_projects.first).to eq(upstream_project)
      end
    end
  end

  context 'when the pipeline is not on the default branch' do
    let(:pipeline) { build(:ci_pipeline, project: project, ref: 'some_branch') }

    it 'does nothing' do
      step.perform!

      expect(project.upstream_projects).to be_empty
    end
  end
end
