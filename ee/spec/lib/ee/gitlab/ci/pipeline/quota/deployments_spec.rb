# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::Ci::Pipeline::Quota::Deployments do
  let_it_be(:namespace) { create(:namespace) }
  let_it_be(:gold_plan, reload: true) { create(:gold_plan) }
  let_it_be(:project, reload: true) { create(:project, :repository, namespace: namespace) }
  let_it_be(:plan_limits) { create(:plan_limits, plan: gold_plan) }
  let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan) }

  let(:pipeline) { build_stubbed(:ci_pipeline, project: project) }

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

  subject { described_class.new(namespace, pipeline, command) }

  shared_context 'limit exceeded' do
    before do
      plan_limits.update!(ci_pipeline_deployments: 1)
    end
  end

  shared_context 'limit not exceeded' do
    before do
      plan_limits.update!(ci_pipeline_deployments: 2)
    end
  end

  describe '#enabled?' do
    context 'when limit is enabled in plan' do
      before do
        plan_limits.update!(ci_pipeline_deployments: 10)
      end

      it 'is enabled' do
        expect(subject).to be_enabled
      end
    end

    context 'when limit is not enabled' do
      before do
        plan_limits.update!(ci_pipeline_deployments: 0)
      end

      it 'is not enabled' do
        expect(subject).not_to be_enabled
      end
    end

    context 'when limit does not exist' do
      before do
        allow(namespace).to receive(:actual_plan) { create(:default_plan) }
      end

      it 'is not enabled' do
        expect(subject).not_to be_enabled
      end
    end
  end

  describe '#exceeded?' do
    context 'when limit is exceeded' do
      include_context 'limit exceeded'

      it 'is exceeded' do
        expect(subject).to be_exceeded
      end
    end

    context 'when limit is not exceeded' do
      include_context 'limit not exceeded'

      it 'is not exceeded' do
        expect(subject).not_to be_exceeded
      end
    end
  end

  describe '#message' do
    context 'when limit is exceeded' do
      include_context 'limit exceeded'

      it 'returns info about pipeline deployment limit exceeded' do
        expect(subject.message)
          .to eq "Pipeline deployment limit exceeded by 1 deployment!"
      end
    end
  end
end
