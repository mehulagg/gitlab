# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Ci::Pipeline::Chain::Limit::Size do
  let_it_be(:namespace) { create(:namespace) }
  let_it_be(:project, reload: true) { create(:project, :repository, namespace: namespace) }
  let_it_be(:user) { create(:user) }

  let(:pipeline) { build(:ci_pipeline, project: project) }

  let(:command) do
    double(:command,
      project: project,
      current_user: user,
      stage_seeds: [double(:seed_1, size: 1), double(:seed_2, size: 1)])
  end

  let(:step) { described_class.new(pipeline, command) }

  subject { step.perform! }

  context 'when pipeline size limit is exceeded' do
    before do
      gold_plan = create(:gold_plan)
      create(:plan_limits, plan: gold_plan, ci_pipeline_size: 1)
      create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
      stub_ci_pipeline_yaml_file(YAML.dump({
        rspec: { script: 'rspec' },
        spinach: { script: 'spinach' }
      }))
    end

    context 'when saving incomplete pipelines' do
      let(:command) do
        double(:command,
          project: project,
          current_user: user,
          save_incompleted: true,
          stage_seeds: [double(:seed_1, size: 1), double(:seed_2, size: 1)])
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

        expect(pipeline.size_limit_exceeded?).to be true
      end

      it 'appends validation error' do
        subject

        expect(pipeline.errors.to_a)
          .to include 'Pipeline size limit exceeded by 1 job!'
      end

      it 'logs the error' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
          instance_of(EE::Gitlab::Ci::Limit::LimitExceededError),
          project_id: project.id, plan: namespace.actual_plan_name
        )

        subject
      end
    end

    context 'when not saving incomplete pipelines' do
      let(:command) do
        double(:command,
          project: project,
          current_user: user,
          save_incompleted: false,
          stage_seeds: [double(:seed_1, size: 1), double(:seed_2, size: 1)])
      end

      it 'does not drop the pipeline' do
        subject

        expect(pipeline).not_to be_failed
      end

      it 'breaks the chain' do
        subject

        expect(step.break?).to be true
      end
    end
  end

  context 'when pipeline size limit is not exceeded' do
    before do
      gold_plan = create(:gold_plan)
      create(:plan_limits, plan: gold_plan, ci_pipeline_size: 100)
      create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
    end

    it 'does not break the chain' do
      subject

      expect(step.break?).to be false
    end

    it 'does not persist the pipeline' do
      subject

      expect(pipeline).not_to be_persisted
    end

    it 'does not log any error' do
      expect(Gitlab::ErrorTracking).not_to receive(:track_exception)

      subject
    end
  end
end
