# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AwardEmoji do
  describe '#update_elastic_associations' do
    let_it_be(:issue) { create(:issue) }
    let_it_be(:merge_request) { create(:merge_request) }

    context 'maintaining_elasticsearch is true' do
      before do
        allow(issue).to receive(:maintaining_elasticsearch?).and_return(true)
        allow(merge_request).to receive(:maintaining_elasticsearch?).and_return(true)
      end

      it 'calls maintain_elasticsearch_update on create' do
        expect(issue).to receive(:maintain_elasticsearch_update)

        create(:award_emoji, :upvote, awardable: issue)
      end

      it 'calls maintain_elasticsearch_update on destroy' do
        award_emoji = create(:award_emoji, :upvote, awardable: issue)

        expect(issue).to receive(:maintain_elasticsearch_update)

        award_emoji.destroy!
      end

      it 'does nothing for other awardable_type' do
        expect(merge_request).not_to receive(:maintain_elasticsearch_update)

        create(:award_emoji, :upvote, awardable: merge_request)
      end
    end

    context 'maintaining_elasticsearch is false' do
      it 'does not call maintain_elasticsearch_update' do
        expect(issue).not_to receive(:maintain_elasticsearch_update)

        award_emoji = create(:award_emoji, :upvote, awardable: issue)

        expect(issue).not_to receive(:maintain_elasticsearch_update)

        award_emoji.destroy!
      end
    end
  end
end
