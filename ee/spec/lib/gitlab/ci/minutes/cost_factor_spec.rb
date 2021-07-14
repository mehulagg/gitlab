# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Minutes::CostFactor do
  using RSpec::Parameterized::TableSyntax

  let(:created_at) { Time.current }
  let(:namespace) { create(:group, shared_runners_minutes_limit: 400, created_at: created_at) }

  let(:project) do
    create(:project,
      group: namespace,
      visibility_level: visibility_level,
      shared_runners_enabled: true
    )
  end

  let(:runner) do
    build_stubbed(:ci_runner,
      runner_type,
      public_projects_minutes_cost_factor: public_cost_factor,
      private_projects_minutes_cost_factor: private_cost_factor
    )
  end

  describe '.new' do
    let(:runner) { build_stubbed(:ci_runner) }

    it 'raises errors when initialized with a runner object' do
      expect { described_class.new(runner) }.to raise_error(ArgumentError)
    end
  end

  describe '#enabled?' do
    subject { described_class.new(runner.runner_matcher).enabled?(project) }

    where(:runner_type, :visibility_level, :public_cost_factor, :private_cost_factor, :result) do
      :project  | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | false
      :project  | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | false
      :project  | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | false
      :group    | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | false
      :group    | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | false
      :group    | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | false
      :instance | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | true
      :instance | Gitlab::VisibilityLevel::PRIVATE  | 1 | 0 | false
      :instance | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | true
      :instance | Gitlab::VisibilityLevel::INTERNAL | 1 | 0 | false
      :instance | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | true
      :instance | Gitlab::VisibilityLevel::PUBLIC   | 0 | 1 | false
    end

    with_them do
      it { is_expected.to eq(result) }
    end
  end

  describe '#disabled?' do
    subject { described_class.new(runner.runner_matcher).disabled?(project) }

    where(:runner_type, :visibility_level, :public_cost_factor, :private_cost_factor, :result) do
      :project  | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | true
      :project  | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | true
      :project  | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | true
      :group    | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | true
      :group    | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | true
      :group    | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | true
      :instance | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | false
      :instance | Gitlab::VisibilityLevel::PRIVATE  | 1 | 0 | true
      :instance | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | false
      :instance | Gitlab::VisibilityLevel::INTERNAL | 1 | 0 | true
      :instance | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | false
      :instance | Gitlab::VisibilityLevel::PUBLIC   | 0 | 1 | true
    end

    with_them do
      it { is_expected.to eq(result) }
    end
  end

  describe '#for_project' do
    subject { described_class.new(runner.runner_matcher).for_project(project) }

    context 'before the public project cost factor release date' do
      let(:created_at) { Date.new(2021, 7, 16) }

      where(:runner_type, :visibility_level, :public_cost_factor, :private_cost_factor, :result) do
        :project  | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | 0
        :project  | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | 0
        :project  | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | 0
        :group    | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | 0
        :group    | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | 0
        :group    | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | 0
        :instance | Gitlab::VisibilityLevel::PUBLIC   | 0 | 5 | 0
        :instance | Gitlab::VisibilityLevel::INTERNAL | 0 | 5 | 5
        :instance | Gitlab::VisibilityLevel::PRIVATE  | 0 | 5 | 5
      end

      with_them do
        it { is_expected.to eq(result) }
      end
    end

    context 'after the public project cost factor release date' do
      let(:created_at) { Date.new(2021, 7, 17) }

      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      where(:runner_type, :visibility_level, :public_cost_factor, :private_cost_factor, :result) do
        :project  | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | 0
        :project  | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | 0
        :project  | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | 0
        :group    | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | 0
        :group    | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | 0
        :group    | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | 0
        :instance | Gitlab::VisibilityLevel::PUBLIC   | 0 | 5 | 0.008
        :instance | Gitlab::VisibilityLevel::INTERNAL | 0 | 5 | 5
        :instance | Gitlab::VisibilityLevel::PRIVATE  | 0 | 5 | 5
      end

      with_them do
        it { is_expected.to eq(result) }
      end
    end
  end

  describe '#for_visibility' do
    subject { described_class.new(runner.runner_matcher).for_visibility(visibility_level) }

    where(:runner_type, :visibility_level, :public_cost_factor, :private_cost_factor, :result) do
      :project  | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | 0
      :project  | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | 0
      :project  | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | 0
      :group    | Gitlab::VisibilityLevel::PRIVATE  | 1 | 1 | 0
      :group    | Gitlab::VisibilityLevel::INTERNAL | 1 | 1 | 0
      :group    | Gitlab::VisibilityLevel::PUBLIC   | 1 | 1 | 0
      :instance | Gitlab::VisibilityLevel::PUBLIC   | 1 | 5 | 1
      :instance | Gitlab::VisibilityLevel::INTERNAL | 1 | 5 | 5
      :instance | Gitlab::VisibilityLevel::PRIVATE  | 1 | 5 | 5
    end

    with_them do
      it { is_expected.to eq(result) }
    end

    context 'with invalid visibility level' do
      let(:visibility_level) { 123 }
      let(:public_cost_factor) { 5 }
      let(:private_cost_factor) { 5 }
      let(:runner_type) { :instance }

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
