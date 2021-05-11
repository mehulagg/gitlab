# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::PipelineCreation::DropNotRunnableBuildsService do
  let_it_be_with_reload(:pipeline) do
    create(:ci_pipeline, status: :created)
  end

  let_it_be_with_reload(:job) do
    create(:ci_build, project: pipeline.project, pipeline: pipeline)
  end

  let_it_be(:instance_runner) do
    create(:ci_runner,
      runner_type: :instance_type,
      public_projects_minutes_cost_factor: 0,
      private_projects_minutes_cost_factor: 1)
  end

  describe '#execute' do
    subject(:execute) { described_class.new(pipeline).execute }

    context 'with public projects' do
      before do
        pipeline.project.update!(visibility_level: ::Gitlab::VisibilityLevel::PUBLIC)
      end

      context 'with available CI quota' do
        it 'does not drop the jobs' do
          expect { execute }.not_to change { job.reload.status }
        end
      end

      context 'when the Ci quota is exceeded' do
        before do
          allow(pipeline.project).to receive(:ci_minutes_quota)
            .and_return(double('quota', minutes_used_up?: true))
        end

        it 'does not drop the jobs' do
          expect { execute }.not_to change { job.reload.status }
        end
      end
    end

    context 'with internal projects' do
      before do
        pipeline.project.update!(visibility_level: ::Gitlab::VisibilityLevel::INTERNAL)
      end

      context 'with available CI quota' do
        it 'does not drop the jobs' do
          expect { execute }.not_to change { job.reload.status }
        end
      end

      context 'when the Ci quota is exceeded' do
        before do
          expect(pipeline.project).to receive(:ci_minutes_quota)
            .and_return(double('quota', minutes_used_up?: true))
        end

        it 'drops the job' do
          execute
          job.reload

          expect(job).to be_failed
          expect(job.failure_reason).to eq('ci_quota_exceeded')
        end
      end
    end

    context 'with private projects' do
      before do
        pipeline.project.update!(visibility_level: ::Gitlab::VisibilityLevel::PRIVATE)
      end

      context 'with available CI quota' do
        it 'does not drop the jobs' do
          expect { execute }.not_to change { job.reload.status }
        end
      end

      context 'when the Ci quota is exceeded' do
        before do
          expect(pipeline.project).to receive(:ci_minutes_quota)
            .and_return(double('quota', minutes_used_up?: true))
        end

        it 'drops the job' do
          execute
          job.reload

          expect(job).to be_failed
          expect(job.failure_reason).to eq('ci_quota_exceeded')
        end
      end
    end
  end
end
