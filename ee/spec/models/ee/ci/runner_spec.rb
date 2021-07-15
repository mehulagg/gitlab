# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Ci::Runner do
  describe '#cost_factor_for_project' do
    subject { runner.cost_factor_for_project(project) }

    context 'with group type runner' do
      let(:runner) { create(:ci_runner, :group) }

      ::Gitlab::VisibilityLevel.options.each do |level_name, level_value|
        context "with #{level_name}" do
          let(:project) { create(:project, visibility_level: level_value) }

          it { is_expected.to eq(0.0) }
        end
      end
    end

    context 'with project type runner' do
      let(:runner) { create(:ci_runner, :project) }

      ::Gitlab::VisibilityLevel.options.each do |level_name, level_value|
        context "with #{level_name}" do
          let(:project) { create(:project, visibility_level: level_value) }

          it { is_expected.to eq(0.0) }
        end
      end
    end

    context 'with instance type runner' do
      let(:runner) do
        create(:ci_runner,
               :instance,
               private_projects_minutes_cost_factor: 1.1,
               public_projects_minutes_cost_factor: 0)
      end

      context 'with private visibility level' do
        let(:project) do
          create(:project,
                 namespace: create(:group, shared_runners_minutes_limit: 400),
                 shared_runners_enabled: true,
                 visibility_level: ::Gitlab::VisibilityLevel::PRIVATE)
        end

        it { is_expected.to eq(1.1) }
      end

      context 'with public visibility level' do
        let(:project) do
          create(:project,
                 namespace: create(:group, shared_runners_minutes_limit: 400, created_at: created_at),
                 shared_runners_enabled: true,
                 visibility_level: ::Gitlab::VisibilityLevel::PUBLIC)
        end

        context 'after the release date for public project cost factors' do
          let(:created_at) { Date.new(2021, 7, 17) }

          before do
            allow(Gitlab).to receive(:com?).and_return(true)
          end

          it { is_expected.to eq(0.008) }
        end

        context 'before the release date for public project cost factors' do
          let(:created_at) { Date.new(2021, 7, 16) }

          it { is_expected.to eq(0.0) }
        end
      end

      context 'with internal visibility level' do
        let(:project) do
          create(:project,
                 namespace: create(:group, shared_runners_minutes_limit: 400),
                 shared_runners_enabled: true,
                 visibility_level: ::Gitlab::VisibilityLevel::INTERNAL)
        end

        it { is_expected.to eq(1.1) }
      end
    end
  end

  describe '#cost_factor_enabled?' do
    let_it_be(:project) do
      namespace = create(:group, shared_runners_minutes_limit: 400, created_at: Date.new(2021, 7, 16))
      create(:project, shared_runners_enabled: true, namespace: namespace)
    end

    context 'when the project has any cost factor' do
      it 'returns true' do
        runner = create(:ci_runner, :instance,
                        private_projects_minutes_cost_factor: 1,
                        public_projects_minutes_cost_factor: 0)

        expect(runner.cost_factor_enabled?(project)).to be_truthy
      end
    end

    context 'when the project has no cost factor' do
      it 'returns false' do
        runner = create(:ci_runner, :instance,
                        private_projects_minutes_cost_factor: 0,
                        public_projects_minutes_cost_factor: 0)

        expect(runner.cost_factor_enabled?(project)).to be_falsy
      end
    end
  end

  describe '#visibility_levels_without_minutes_quota' do
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
