# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Ci::Pipeline::Chain::Limit::Deployments do
  let_it_be(:namespace) { create(:namespace) }
  let_it_be(:project, reload: true) { create(:project, namespace: namespace) }

  let(:stage_seeds) do
    [
      double(:test, seeds: [
        double(:test, attributes: {})
      ]),
      double(:staging, seeds: [
        double(:staging, attributes: { environment: 'staging' })
      ]),
      double(:production, seeds: [
        double(:production, attributes: { environment: 'production' })
      ])
    ]
  end

  let(:command) do
    double(:command,
      project: project,
      stage_seeds: stage_seeds,
      save_incompleted: true
    )
  end

  let(:pipeline) { build(:ci_pipeline, project: project) }
  let(:step) { described_class.new(pipeline, command) }

  subject { step.perform! }

  context 'when pipeline deployments limit is exceeded' do
    before do
      gold_plan = create(:gold_plan)
      create(:plan_limits, plan: gold_plan, ci_pipeline_deployments: 1)
      create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
    end

    it 'drops the pipeline' do
      subject

      expect(pipeline.reload).to be_failed
    end

    it 'persists the pipeline' do
      subject

      expect(pipeline).to be_persisted
    end

    it 'breaks the chain' do
      subject

      expect(step.break?).to be true
    end

    it 'sets a valid failure reason' do
      subject

      expect(pipeline.deployments_limit_exceeded?).to be true
    end

    it 'logs the error' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        instance_of(EE::Gitlab::Ci::Limit::LimitExceededError),
        project_id: project.id, plan: namespace.actual_plan_name
      )

      subject
    end
  end

  context 'when job activity limit is not exceeded' do
    before do
      gold_plan = create(:gold_plan)
      create(:plan_limits, plan: gold_plan, ci_pipeline_deployments: 100)
      create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
    end

    it 'does not break the chain' do
      subject

      expect(step.break?).to be false
    end

    it 'does not invalidate the pipeline' do
      subject

      expect(pipeline.errors).to be_empty
    end

    it 'does not log any error' do
      expect(Gitlab::ErrorTracking).not_to receive(:track_exception)

      subject
    end
  end
end
