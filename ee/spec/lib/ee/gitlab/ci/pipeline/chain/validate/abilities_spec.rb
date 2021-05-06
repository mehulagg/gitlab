# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Chain::Validate::Abilities do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }

  let(:pipeline) do
    build_stubbed(:ci_pipeline, project: project)
  end

  let(:command) do
    Gitlab::Ci::Pipeline::Chain::Command
      .new(project: project, current_user: user, origin_ref: ref)
  end

  let(:step) { described_class.new(pipeline, command) }
  let(:ref) { 'master' }

  describe '#perform!' do
    before do
      project.add_developer(user)
    end

    context 'when triggering builds for project mirrors is disabled' do
      it 'returns an error' do
        allow(command)
          .to receive(:allow_mirror_update)
          .and_return(true)

        allow(project)
          .to receive(:mirror_trigger_builds?)
          .and_return(false)

        step.perform!

        expect(pipeline.errors.to_a)
          .to include('Pipeline is disabled for mirror updates')
      end
    end

    describe 'credit card requirement' do
      using RSpec::Parameterized::TableSyntax

      where(:is_saas, :cc_present, :is_free, :is_trial, :free_ff_enabled, :trial_ff_enabled, :valid) do
        # self-hosted
        false | false | false | false | true  | true  | true  # paid plan
        false | false | false | true  | true  | true  | true  # missing CC on trial plan

        # saas
        true  | false | false | false | true  | true  | true  # missing CC on paid plan
        true  | false | true  | false | true  | true  | false # missing CC on free plan
        true  | false | true  | false | false | true  | true  # missing CC on free plan - FF off
        true  | false | false | true  | true  | true  | false # missing CC on trial plan
        true  | false | false | true  | true  | false | true  # missing CC on trial plan - FF off
        true  | true  | true  | false | true  | true  | true  # present CC on free plan
        true  | true  | false | true  | true  | true  | true  # present CC on trial plan
      end

      with_them do
        before do
          allow(::Gitlab).to receive(:com?).and_return(is_saas)
          allow(user).to receive(:credit_card_validated_at).and_return(Time.current) if cc_present
          allow(project.namespace).to receive(:free_plan?).and_return(is_free)
          allow(project.namespace).to receive(:trial?).and_return(is_trial)
          stub_feature_flags(
            ci_require_credit_card_on_free_plan: free_ff_enabled,
            ci_require_credit_card_on_trial_plan: trial_ff_enabled)
        end

        it 'runs the checks', :aggregate_failures do
          step.perform!

          if valid
            expect(step.break?).to be_falsey
            expect(pipeline.errors).to be_empty
          else
            expect(step.break?).to be_truthy
            expect(pipeline.errors.to_a)
              .to include('Credit card required to be on file in order to create a pipeline')
          end
        end
      end
    end
  end
end
