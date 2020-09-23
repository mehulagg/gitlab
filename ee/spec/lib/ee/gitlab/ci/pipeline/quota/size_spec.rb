# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::Ci::Pipeline::Quota::Size do
  let_it_be(:namespace) { create(:namespace) }
  let_it_be(:gold_plan, reload: true) { create(:gold_plan) }
  let_it_be(:project, reload: true) { create(:project, :repository, namespace: namespace) }
  let_it_be(:plan_limits) { create(:plan_limits, plan: gold_plan) }
  let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan) }

  let(:pipeline) { build_stubbed(:ci_pipeline, project: project) }

  let(:command) do
    double(:command,
      stage_seeds: [double(:seed_1, size: 1), double(:seed_2, size: 1)])
  end

  subject { described_class.new(namespace, pipeline, command) }

  shared_context 'pipeline size limit exceeded' do
    before do
      config = YAML.dump({
        rspec: { script: 'rspec' },
        spinach: { script: 'spinach' }
      })
      stub_ci_pipeline_yaml_file(config)
      plan_limits.update!(ci_pipeline_size: 1)
    end
  end

  shared_context 'pipeline size limit not exceeded' do
    before do
      config = YAML.dump({
        rspec: { script: 'rspec' }
      })
      stub_ci_pipeline_yaml_file(config)
      plan_limits.update!(ci_pipeline_size: 2)
    end
  end

  describe '#enabled?' do
    context 'when limit is enabled in plan' do
      before do
        plan_limits.update!(ci_pipeline_size: 10)
      end

      it 'is enabled' do
        expect(subject).to be_enabled
      end
    end

    context 'when limit is not enabled' do
      before do
        plan_limits.update!(ci_pipeline_size: 0)
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
      include_context 'pipeline size limit exceeded'

      it 'is exceeded' do
        expect(subject).to be_exceeded
      end
    end

    context 'when limit is not exceeded' do
      include_context 'pipeline size limit not exceeded'

      it 'is not exceeded' do
        expect(subject).not_to be_exceeded
      end
    end
  end

  describe '#message' do
    context 'when limit is exceeded' do
      include_context 'pipeline size limit exceeded'

      it 'returns infor about pipeline size limit exceeded' do
        expect(subject.message)
          .to eq "Pipeline size limit exceeded by 1 job!"
      end
    end
  end
end
