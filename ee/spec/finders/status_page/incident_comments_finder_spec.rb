# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StatusPage::IncidentCommentsFinder do
  let_it_be(:user) { create(:user) }
  let_it_be(:issue) { create(:issue) }
  let_it_be(:unrelated_issue) { create(:issue, project: issue.project) }

  let_it_be(:visible_emoji) { described_class::AWARD_EMOJI }
  let_it_be(:other_emoji) { 'cool' }

  let_it_be(:notes) do
    {
      to_publish: Array.new(2) { note(emoji: visible_emoji) },
      system: note(system: true),
      invisible_without_emoji: note,
      invisible_with_other_emoji: note(emoji: other_emoji),
      unrelated: note(for_issue: unrelated_issue)
    }
  end

  let(:notes_to_publish) { notes.fetch(:to_publish) }
  let(:finder) { described_class.new(issue: issue) }

  describe '#all' do
    let(:sorted_notes) { notes_to_publish.sort_by(&:created_at) }

    subject { finder.all }

    before do
      stub_const("#{described_class}::MAX_LIMIT", limit)
    end

    context 'when limit is higher than the colletion size' do
      let(:limit) { notes_to_publish.size + 1 }

      it { is_expected.to eq(sorted_notes) }
    end

    context 'when limit is lower than the colletion size' do
      let(:limit) { notes_to_publish.size - 1 }

      it { is_expected.to eq(sorted_notes.first(1)) }
    end
  end

  describe 'award emoji' do
    let(:digest_path) { Rails.root.join(*%w[fixtures emojis digests.json]) }
    let(:digest_json) { Gitlab::Json.parse(File.read(digest_path)) }

    it 'ensures that emoji exists' do
      expect(digest_json).to include(visible_emoji)
    end
  end

  private

  def note(for_issue: issue, emoji: nil, **kwargs)
    note = create(:note, project: for_issue.project, noteable: for_issue, **kwargs)
    create(:award_emoji, awardable: note, name: emoji, user: user) if emoji

    note
  end
end
