# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequest::CleanupSchedule do
  describe 'associations' do
    it { is_expected.to belong_to(:merge_request) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:scheduled_at) }
  end

  describe '.scheduled_and_unstarted' do
    let!(:cleanup_schedule_1) { create(:merge_request_cleanup_schedule, scheduled_at: 2.days.ago) }
    let!(:cleanup_schedule_2) { create(:merge_request_cleanup_schedule, scheduled_at: 1.day.ago) }
    let!(:cleanup_schedule_3) { create(:merge_request_cleanup_schedule, :completed, scheduled_at: 1.day.ago) }
    let!(:cleanup_schedule_4) { create(:merge_request_cleanup_schedule, scheduled_at: 4.days.ago) }
    let!(:cleanup_schedule_5) { create(:merge_request_cleanup_schedule, scheduled_at: 3.days.ago) }
    let!(:cleanup_schedule_6) { create(:merge_request_cleanup_schedule, scheduled_at: 1.day.from_now) }
    let!(:cleanup_schedule_7) { create(:merge_request_cleanup_schedule, :failed, scheduled_at: 5.days.ago) }

    it 'returns records that are scheduled before or on current time and unstarted (ordered by scheduled first)' do
      expect(described_class.scheduled_and_unstarted).to eq([
        cleanup_schedule_2,
        cleanup_schedule_1,
        cleanup_schedule_5,
        cleanup_schedule_4
      ])
    end
  end

  describe '.next_scheduled' do
    let!(:cleanup_schedule_1) { create(:merge_request_cleanup_schedule, :completed, scheduled_at: 1.day.ago) }
    let!(:cleanup_schedule_2) { create(:merge_request_cleanup_schedule, scheduled_at: 2.days.ago) }
    let!(:cleanup_schedule_3) { create(:merge_request_cleanup_schedule, :running, scheduled_at: 1.day.ago) }
    let!(:cleanup_schedule_4) { create(:merge_request_cleanup_schedule, scheduled_at: 3.days.ago) }
    let!(:cleanup_schedule_5) { create(:merge_request_cleanup_schedule, :failed, scheduled_at: 3.days.ago) }

    it 'finds the next scheduled and unstarted then marked it as running' do
      expect(described_class.next_scheduled).to eq(cleanup_schedule_2)
      expect(cleanup_schedule_2.reload).to be_running
    end
  end
end
