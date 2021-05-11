# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::BuildMatcher::Factory::PipelineStrategy do
  let_it_be(:pipeline) { create(:ci_pipeline, :protected) }

  describe '.applies_to?' do
    it { expect(described_class.applies_to?(pipeline)).to be_truthy }

    it { expect(described_class.applies_to?(nil)).to be_falsey }
  end

  describe '.build_from' do
    subject(:matchers) { described_class.build_from(pipeline) }

    context 'when the pipeline is empty' do
      it 'does not throw errors' do
        is_expected.to be_truthy
      end
    end

    context 'when the pipeline has builds' do
      let_it_be(:build_without_tags) do
        create(:ci_build, pipeline: pipeline)
      end

      let_it_be(:build_with_tags) do
        create(:ci_build, pipeline: pipeline, tag_list: %w[tag1 tag2])
      end

      let_it_be(:other_build_with_tags) do
        create(:ci_build, pipeline: pipeline, tag_list: %w[tag2 tag1])
      end

      it { expect(matchers.size).to eq(2) }

      it 'groups build ids' do
        expect(matchers.map(&:build_ids)).to match_array([
          [build_without_tags.id],
          match_array([build_with_tags.id, other_build_with_tags.id])
        ])
      end

      it { expect(matchers.map(&:tag_list)).to match_array([[], %w[tag1 tag2]]) }

      it { expect(matchers).to all be_protected }

      context 'when the pipeline is not protected' do
        before do
          pipeline.update!(protected: false)
        end

        it { expect(matchers.map(&:protected?)).to all be_falsey }
      end
    end

    context 'when the pipeline has bridges' do
      let_it_be(:bridge) { create(:ci_bridge, pipeline: pipeline) }

      it { expect(matchers).to be_empty }
    end
  end
end
