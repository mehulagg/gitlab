# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::RunnerMatcher::Factory::RelationStrategy do
  describe '.applies_to?' do
    it { expect(described_class.applies_to?(Ci::Runner.none)).to be_truthy }

    it { expect(described_class.applies_to?(build_stubbed(:ci_runner))).to be_falsey }
  end

  describe '.build_from' do
    subject(:matchers) { described_class.build_from(Ci::Runner.all) }

    context 'deduplicates on runner_type' do
      before do
        create_list(:ci_runner, 2, :instance)
        create_list(:ci_runner, 2, :project)
      end

      it 'creates two matchers' do
        expect(matchers.size).to eq(2)

        expect(matchers.map(&:runner_type)).to match_array(%w[instance_type project_type])
      end
    end

    context 'deduplicates on public_projects_minutes_cost_factor' do
      before do
        create_list(:ci_runner, 2, public_projects_minutes_cost_factor: 5)
        create_list(:ci_runner, 2, public_projects_minutes_cost_factor: 10)
      end

      it 'creates two matchers' do
        expect(matchers.size).to eq(2)

        expect(matchers.map(&:public_projects_minutes_cost_factor)).to match_array([5, 10])
      end
    end

    context 'deduplicates on private_projects_minutes_cost_factor' do
      before do
        create_list(:ci_runner, 2, private_projects_minutes_cost_factor: 5)
        create_list(:ci_runner, 2, private_projects_minutes_cost_factor: 10)
      end

      it 'creates two matchers' do
        expect(matchers.size).to eq(2)

        expect(matchers.map(&:private_projects_minutes_cost_factor)).to match_array([5, 10])
      end
    end

    context 'deduplicates on run_untagged' do
      before do
        create_list(:ci_runner, 2, run_untagged: true, tag_list: ['a'])
        create_list(:ci_runner, 2, run_untagged: false, tag_list: ['a'])
      end

      it 'creates two matchers' do
        expect(matchers.size).to eq(2)

        expect(matchers.map(&:run_untagged)).to match_array([true, false])
      end
    end

    context 'deduplicates on access_level' do
      before do
        create_list(:ci_runner, 2, access_level: :ref_protected)
        create_list(:ci_runner, 2, access_level: :not_protected)
      end

      it 'creates two matchers' do
        expect(matchers.size).to eq(2)

        expect(matchers.map(&:access_level)).to match_array(%w[ref_protected not_protected])
      end
    end

    context 'deduplicates on tag_list' do
      before do
        create_list(:ci_runner, 2, tag_list: %w[tag1 tag2])
        create_list(:ci_runner, 2, tag_list: %w[tag3 tag4])
      end

      it 'creates two matchers' do
        expect(matchers.size).to eq(2)

        expect(matchers.map(&:tag_list)).to match_array([%w[tag1 tag2], %w[tag3 tag4]])
      end
    end
  end
end
