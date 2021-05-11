# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::RunnerMatcher::Factory::RecordStrategy do
  let_it_be(:runner) do
    create(:ci_runner, :instance_type, tag_list: %w[tag1 tag2])
  end

  describe '.applies_to?' do
    it { expect(described_class.applies_to?(runner)).to be_truthy }

    it { expect(described_class.applies_to?(Ci::Runner.none)).to be_falsey }
  end

  describe '.build_from' do
    subject(:matchers) { described_class.build_from(runner) }

    let(:matcher) { matchers.first }

    it { expect(matchers.size).to eq(1) }

    it { expect(matcher.runner_type).to eq(runner.runner_type) }

    it { expect(matcher.public_projects_minutes_cost_factor).to eq(runner.public_projects_minutes_cost_factor) }

    it { expect(matcher.private_projects_minutes_cost_factor).to eq(runner.private_projects_minutes_cost_factor) }

    it { expect(matcher.run_untagged).to eq(runner.run_untagged) }

    it { expect(matcher.access_level).to eq(runner.access_level) }

    it { expect(matcher.tag_list).to match_array(runner.tag_list) }
  end
end
