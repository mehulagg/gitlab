# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::EnforcePipelineQuotaService do
  let_it_be(:namespace) do
    create(:group,
      :with_namespace_statistics,
      shared_runners_enabled: true,
      shared_runners_seconds: 1.hour,
      shared_runners_minutes_limit: 10)
  end

  let_it_be(:project) { create(:project, namespace: namespace) }
  let_it_be(:user) { create(:user) }

  let_it_be(:pipeline) do
    create(:ci_pipeline, :with_job, project: project, status: :created)
  end

  let(:job) do
    pipeline.builds.first
  end

  let(:service) do
    described_class.new(project, user)
  end

  subject(:execute) { service.execute(pipeline) }

  shared_examples 'a failed build' do
    it 'fails the build' do
      execute
      job.reload

      expect(job).to be_failed
      expect(job.failure_reason).to eq('ci_quota_exceeded')
    end
  end

  shared_examples 'an unchanged build' do
    it { expect { execute }.not_to change { job.reload.status } }
  end

  context 'when shared runners are enabled' do
    context 'when usage exceed the limit' do
      context 'when the feature flag is disabled' do
        before do
          stub_feature_flags(ci_drop_new_builds_when_ci_quota_exceeded: false)
        end

        it_behaves_like 'an unchanged build'
      end

      it_behaves_like 'a failed build'

      context 'when the project has specific runners assigned' do
        let_it_be(:runner) do
          create(:ci_runner, :online, runner_type: :project_type, projects: [project])
        end

        it_behaves_like 'an unchanged build'

        context 'when the runner is offline' do
          before do
            runner.update!(contacted_at: 3.days.ago)
          end

          it_behaves_like 'a failed build'
        end
      end

      context 'when the namespace has specific runners assigned' do
        let_it_be(:runner) do
          create(:ci_runner, :online, runner_type: :group_type, groups: [namespace])
        end

        it_behaves_like 'an unchanged build'

        context 'when the runner is offline' do
          before do
            runner.update!(contacted_at: 3.days.ago)
          end

          it_behaves_like 'a failed build'
        end
      end
    end

    context 'when usage is below limit' do
      before do
        namespace.namespace_statistics.update!(shared_runners_seconds: 1.minute)
      end

      it_behaves_like 'an unchanged build'
    end
  end

  context 'when shared runners are disabled' do
    before do
      namespace.update!(shared_runners_enabled: false)
    end

    it_behaves_like 'an unchanged build'
  end
end
