# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::RunnerMatcher do
  let(:dummy_attributes) do
    {
      runner_type: 'instance_type',
      public_projects_minutes_cost_factor: 0.0,
      private_projects_minutes_cost_factor: 1.0,
      run_untagged: false,
      access_level: 'ref_protected',
      tag_list: %w[tag1 tag2]
    }
  end

  describe '#matches_quota?' do
    let(:project) { build_stubbed(:project, project_attributes) }

    let(:build) do
      build_stubbed(:ci_build, project: project)
    end

    let(:runner_matcher) do
      described_class.new(dummy_attributes.merge(runner_attributes))
    end

    let(:visibility_map) do
      {
        public:   ::Gitlab::VisibilityLevel::PUBLIC,
        internal: ::Gitlab::VisibilityLevel::INTERNAL,
        private:  ::Gitlab::VisibilityLevel::PRIVATE
      }
    end

    subject { runner_matcher.matches_quota?(record) }

    shared_examples 'matches quota to runner types' do
      using RSpec::Parameterized::TableSyntax

      where(:runner_type, :project_visibility_level, :quota_minutes_used_up, :result) do
        :project_type   | :public                  | true                  | true
        :project_type   | :internal                | true                  | true
        :project_type   | :private                 | true                  | true

        :instance_type  | :public                  | true                  | true
        :instance_type  | :public                  | false                 | true

        :instance_type  | :internal                | true                  | false
        :instance_type  | :internal                | false                 | true

        :instance_type  | :private                 | true                  | false
        :instance_type  | :private                 | false                 | true
      end
      with_them do
        let(:runner_attributes) do
          { runner_type: runner_type }
        end

        let(:project_attributes) do
          { visibility_level: visibility_map[project_visibility_level] }
        end

        before do
          allow(project)
            .to receive(:ci_minutes_quota)
            .and_return(double(minutes_used_up?: quota_minutes_used_up))
        end

        it { is_expected.to eq(result) }
      end
    end

    context 'with an instance of BuildMatcher' do
      it_behaves_like 'matches quota to runner types' do
        let(:record) { Gitlab::Ci::Matching::BuildMatcher.for(build).first }
      end
    end

    context 'with an instance of Ci::Build' do
      it_behaves_like 'matches quota to runner types' do
        let(:record) { build }
      end
    end
  end
end
