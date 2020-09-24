# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UpdateBuildMinutesService do
  describe '#perform' do
    let(:namespace) { create(:namespace, shared_runners_minutes_limit: 100) }
    let(:project) { create(:project, :public, namespace: namespace) }
    let(:pipeline) { create(:ci_pipeline, project: project) }
    let(:build) do
      create(:ci_build, :success,
        runner: runner, pipeline: pipeline,
        started_at: 2.hours.ago, finished_at: 1.hour.ago)
    end

    subject { described_class.new(project, nil).execute(build) }

    context 'with shared runner' do
      let(:cost_factor) { 2.0 }
      let(:runner) { create(:ci_runner, :instance, public_projects_minutes_cost_factor: cost_factor) }

      it "creates a statistics and sets duration with applied cost factor" do
        subject

        expect(project.statistics.reload.shared_runners_seconds)
          .to eq(build.duration.to_i * 2)

        expect(namespace.namespace_statistics.reload.shared_runners_seconds)
          .to eq(build.duration.to_i * 2)
      end

      context 'when statistics are created' do
        before do
          project.statistics.update(shared_runners_seconds: 100)
          namespace.create_namespace_statistics(shared_runners_seconds: 100)
        end

        it "updates statistics and adds duration with applied cost factor" do
          subject

          expect(project.statistics.reload.shared_runners_seconds)
            .to eq(100 + build.duration.to_i * 2)

          expect(namespace.namespace_statistics.reload.shared_runners_seconds)
            .to eq(100 + build.duration.to_i * 2)
        end
      end

      context 'when namespace is subgroup' do
        let(:root_ancestor) { create(:group, shared_runners_minutes_limit: 100) }
        let(:namespace) { create(:namespace, parent: root_ancestor) }

        it 'creates a statistics in root namespace' do
          subject

          expect(root_ancestor.namespace_statistics.reload.shared_runners_seconds)
            .to eq(build.duration.to_i * 2)
        end
      end

      context 'when cost factor has non-zero fractional part' do
        let(:cost_factor) { 1.234 }

        it 'truncates the result product value' do
          subject

          expect(project.statistics.reload.shared_runners_seconds)
            .to eq((build.duration.to_i * 1.234).to_i)

          expect(namespace.namespace_statistics.reload.shared_runners_seconds)
            .to eq((build.duration.to_i * 1.234).to_i)
        end
      end
    end

    context 'for specific runner' do
      let(:runner) { create(:ci_runner, :project) }

      it "does not create statistics" do
        subject

        expect(namespace.namespace_statistics).to be_nil
      end
    end
  end
end
