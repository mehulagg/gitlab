# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::BuildMatcher::Factory::BuildStrategy do
  let_it_be(:pipeline) { create(:ci_pipeline, :protected) }

  let_it_be(:build) do
    create(:ci_build, pipeline: pipeline, tag_list: %w[tag1 tag2])
  end

  describe '.applies_to?' do
    it { expect(described_class.applies_to?(build)).to be_truthy }

    it { expect(described_class.applies_to?(pipeline)).to be_falsey }
  end

  describe '.build_from' do
    subject(:matchers) { described_class.build_from(build) }

    let(:matcher) { matchers.first }

    it { expect(matchers.size).to eq(1) }

    it { expect(matcher.build_ids).to eq([build.id]) }

    it { expect(matcher.tag_list).to match_array(%w[tag1 tag2]) }

    it { expect(matcher.protected?).to eq(build.protected?) }

    it { expect(matcher.project).to eq(build.project) }
  end
end
