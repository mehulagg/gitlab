# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequest::Metrics do
  describe '#review_start_at' do
    it 'is the earliest date from first_comment_at, first_approved_at or first_reassigned_at' do
      subject.first_approved_at = 1.hour.ago
      subject.first_comment_at = 1.day.ago
      subject.first_reassigned_at = 1.week.ago

      expect(subject.review_start_at).to be_like_time(1.week.ago)
    end

    context 'when all review start candidates are nil' do
      it 'is nil' do
        expect(subject.review_start_at).to eq nil
      end
    end

    context 'when one of review start candidates is nil' do
      it 'is earliest date from non-nil values' do
        subject.first_approved_at = 1.day.ago
        subject.first_reassigned_at = 1.hour.ago

        expect(subject.review_start_at).to be_like_time(1.day.ago)
      end
    end
  end

  describe '#review_end_at' do
    context 'when MR is merged' do
      before do
        subject.merged_at = 1.day.ago
      end

      it 'is merged_at' do
        expect(subject.review_end_at).to be_like_time(1.day.ago)
      end
    end

    context 'when MR is not merged' do
      it 'is Time.current' do
        expect(subject.review_end_at).to be_like_time(Time.current)
      end
    end
  end

  describe '#review_time' do
    it 'is nil if there is no review_start_at' do
      expect(subject.review_time).to eq nil
    end

    it 'is review_end_at - review_start_at' do
      subject.merged_at = 1.day.ago
      subject.first_comment_at = 1.week.ago

      expect(subject.review_time).to be_like_time(6.days)
    end
  end
end
