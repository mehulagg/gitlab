# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::RefreshCommentsData do
  describe '.for_note' do
    subject { described_class.for_note(note) }

    context 'for non-commit, non-mr note' do
      let(:note) { create(:note, :on_issue) }

      it { is_expected.to be_nil }
    end

    context 'for MR note' do
      let(:note) { create(:note, :on_merge_request) }

      it 'returns refresh comments instance for note MR' do
        expected_mock = instance_double(described_class)

        allow(described_class).to receive(:new).with(note.noteable).and_return(expected_mock)

        expect(subject).to eq expected_mock
      end
    end

    context 'for commit note' do
      let(:note) { create(:diff_note_on_commit, author: create(:user)) }
      let!(:merge_request) { create :merge_request, source_project: note.project }

      before do
        allow(note.noteable).to receive(:merge_requests).and_return(note.project.merge_requests)
      end

      it 'returns refresh comments instance for commit MR' do
        expected_mock = instance_double(described_class)

        allow(described_class).to receive(:new).with(merge_request).and_return(expected_mock)

        expect(subject).to eq expected_mock
      end
    end
  end

  describe '#execute' do
    subject { described_class.new(merge_request) }

    let(:merge_request) { create :merge_request }
    let(:calculated_value) { 2.days.ago.beginning_of_day }

    include_examples 'common merge request metric refresh for', :first_comment_at
  end
end
