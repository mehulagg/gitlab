# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Minutes::CostFactor do
  using RSpec::Parameterized::TableSyntax

  let(:runner) do
    build_stubbed(:ci_runner,
      runner_type,
      public_projects_minutes_cost_factor: public_cost_factor,
      private_projects_minutes_cost_factor: private_cost_factor
    )
  end

  describe '#enabled?' do
    subject { described_class.new(runner).enabled?(visibility_level) }

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
    subject { described_class.new(runner).disabled?(visibility_level) }

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

  describe '#for_visibility' do
    subject { described_class.new(runner).for_visibility(visibility_level) }

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
