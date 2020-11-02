# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Chain::CancelPendingPipelines do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:prev_pipeline) { create(:ci_pipeline, project: project) }
  let(:new_commit) { create(:commit, project: project)  }
  let(:pipeline) { create(:ci_pipeline, project: project, sha: new_commit.sha) }

  let(:command) do
    Gitlab::Ci::Pipeline::Chain::Command.new(project: project, current_user: user)
  end

  let(:step) { described_class.new(pipeline, command) }

  before do
    create(:ci_build, :interruptible, :running, project: project, pipeline: prev_pipeline)
    create(:ci_build, :interruptible, :success, project: project, pipeline: prev_pipeline)
    create(:ci_build, :created, project: project, pipeline: prev_pipeline)

    create(:ci_build, :interruptible, project: project, pipeline: pipeline)
  end

  describe '#perform!' do
    subject { step.perform! }

    before do
      expect(prev_pipeline.builds.pluck(:status)).to contain_exactly('running', 'success', 'created')
      expect(pipeline.builds.pluck(:status)).to contain_exactly('pending')
    end

    context 'when auto-cancel is enabled' do
      before do
        project.update!(auto_cancel_pending_pipelines: 'enabled')
      end

      it 'cancels only previous interruptible builds' do
        subject

        expect(prev_pipeline.builds.pluck(:status)).to contain_exactly('canceled', 'success', 'canceled')
        expect(pipeline.builds.pluck(:status)).to contain_exactly('pending')
      end

      context 'when the previous pipeline has a child pipeline' do
        let(:child_pipeline) { create(:ci_pipeline, child_of: prev_pipeline) }

        before do
          create(:ci_build, :interruptible, :running, project: project, pipeline: child_pipeline)
        end

        it 'cancels interruptible builds of child pipeline' do
          expect(child_pipeline.builds.pluck(:status)).to contain_exactly('running')

          subject

          expect(child_pipeline.builds.pluck(:status)).to contain_exactly('canceled')
        end

        context 'when FF ci_auto_cancel_all_pipelines is disabled' do
          before do
            stub_feature_flags(ci_auto_cancel_all_pipelines: false)
          end

          it 'does not cancel interruptible builds of child pipeline' do
            expect(child_pipeline.builds.pluck(:status)).to contain_exactly('running')

            subject

            expect(child_pipeline.builds.pluck(:status)).to contain_exactly('running')
          end
        end
      end
    end

    context 'when auto-cancel is disabled' do
      before do
        project.update!(auto_cancel_pending_pipelines: 'disabled')
      end

      it 'does not cancel any build' do
        subject

        expect(prev_pipeline.builds.pluck(:status)).to contain_exactly('running', 'success', 'created')
        expect(pipeline.builds.pluck(:status)).to contain_exactly('pending')
      end
    end
  end
end
