# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Ci::Runner do
  describe '#tick_runner_queue' do
    it 'sticks the runner to the primary and calls the original method' do
      runner = create(:ci_runner)

      allow(Gitlab::Database::LoadBalancing).to receive(:enable?)
        .and_return(true)

      expect(Gitlab::Database::LoadBalancing::Sticking).to receive(:stick)
        .with(:runner, runner.id)

      expect(Gitlab::Workhorse).to receive(:set_key_and_notify)

      runner.tick_runner_queue
    end
  end

  describe '#minutes_cost_factor' do
    subject { runner.minutes_cost_factor(visibility_level) }

    context 'with group type runner' do
      let(:runner) { create(:ci_runner, :group) }

      ::Gitlab::VisibilityLevel.options.each do |level_name, level_value|
        context "with #{level_name}" do
          let(:visibility_level) {level_value}

          it { is_expected.to eq(0.0) }
        end
      end
    end

    context 'with project type runner' do
      let(:runner) { create(:ci_runner, :project) }

      ::Gitlab::VisibilityLevel.options.each do |level_name, level_value|
        context "with #{level_name}" do
          let(:visibility_level) {level_value}

          it { is_expected.to eq(0.0) }
        end
      end
    end

    context 'with instance type runner' do
      let(:runner) do
        create(:ci_runner,
               :instance,
               private_projects_minutes_cost_factor: 1.1,
               public_projects_minutes_cost_factor: 2.2)
      end

      context 'with private visibility level' do
        let(:visibility_level) { ::Gitlab::VisibilityLevel::PRIVATE }

        it { is_expected.to eq(1.1) }
      end

      context 'with public visibility level' do
        let(:visibility_level) { ::Gitlab::VisibilityLevel::PUBLIC }

        it { is_expected.to eq(2.2) }
      end

      context 'with internal visibility level' do
        let(:visibility_level) { ::Gitlab::VisibilityLevel::INTERNAL }

        it { is_expected.to eq(1.1) }
      end

      context 'with invalid visibility level' do
        let(:visibility_level) { 123 }

        it 'raises an error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '#matches_build?' do
    let_it_be(:ultimate_plan) { create(:ultimate_plan) }
    let_it_be(:plan_limits) { create(:plan_limits, plan: ultimate_plan) }
    let_it_be(:runner) { create(:ci_runner, :instance) }

    let(:namespace) { create(:namespace) }
    let(:user) { create(:user) }
    let(:project) { create(:project, namespace: namespace, creator: user) }
    let(:build) { create(:ci_build, project: project, user: user) }
    let(:project_runner) { create(:ci_runner, :project, projects: [project]) }

    describe 'credit card requirement' do
      before do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: ultimate_plan)
      end

      shared_examples 'matches the build' do
        it 'returns true for both runners' do
          expect(runner.matches_build?(build)).to be true
          expect(project_runner.matches_build?(build)).to be true
        end
      end

      it_behaves_like 'matches the build'

      context 'when credit card is required' do
        context 'when project is on free plan' do
          before do
            allow(::Gitlab).to receive(:com?).and_return(true)
            namespace.gitlab_subscription.update!(hosted_plan: create(:free_plan))
            user.created_at = ::Users::CreditCardValidation::RELEASE_DAY
          end

          context 'when user has credit card' do
            before do
              allow(user).to receive(:credit_card_validated_at).and_return(Time.current)
            end

            it_behaves_like 'matches the build'
          end

          context 'when user does not have credit card' do
            it 'returns false for the instance runner' do
              expect(runner.matches_build?(build)).to be false
            end

            it 'returns true for the project runner' do
              expect(project_runner.matches_build?(build)).to be true
            end

            context 'when feature flag is disabled' do
              before do
                stub_feature_flags(ci_require_credit_card_on_free_plan: false)
              end

              it_behaves_like 'matches the build'
            end
          end
        end
      end
    end
  end

  describe `#visibility_levels_without_minutes_quota` do
    subject { runner.visibility_levels_without_minutes_quota }

    context 'with group type runner' do
      let(:runner) { create(:ci_runner, :group) }

      it { is_expected.to match(::Gitlab::VisibilityLevel.options.values) }
    end

    context 'with project type runner' do
      let(:runner) { create(:ci_runner, :project) }

      it { is_expected.to match(::Gitlab::VisibilityLevel.options.values) }
    end

    context 'with instance type runner' do
      context 'with both public and private cost factor being positive' do
        let(:runner) do
          create(:ci_runner,
                :instance,
                private_projects_minutes_cost_factor: 1.1,
                public_projects_minutes_cost_factor: 2.2)
        end

        it { is_expected.to eq([]) }
      end

      context 'with both public and private cost factor being zero' do
        let(:runner) do
          create(:ci_runner,
                :instance,
                private_projects_minutes_cost_factor: 0.0,
                public_projects_minutes_cost_factor: 0.0)
        end

        it { is_expected.to match(::Gitlab::VisibilityLevel.options.values) }
      end

      context 'with only private cost factor being positive' do
        let(:runner) do
          create(:ci_runner,
                :instance,
                private_projects_minutes_cost_factor: 1.0,
                public_projects_minutes_cost_factor: 0.0)
        end

        it { is_expected.to match([::Gitlab::VisibilityLevel::PUBLIC]) }
      end
    end
  end
end
