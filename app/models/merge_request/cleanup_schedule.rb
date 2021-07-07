# frozen_string_literal: true

class MergeRequest::CleanupSchedule < ApplicationRecord
  belongs_to :merge_request, inverse_of: :cleanup_schedule

  validates :scheduled_at, presence: true

  enum status: { unstarted: 0, running: 1, completed: 3, failed: 4 }

  scope :recent, -> { order('scheduled_at DESC') }
  scope :scheduled_and_unstarted, -> { where('completed_at IS NULL AND scheduled_at <= NOW()').unstarted.recent }

  def self.next_scheduled
    MergeRequest::CleanupSchedule.transaction do
      cleanup_schedule = scheduled_and_unstarted.lock('FOR UPDATE SKIP LOCKED').first

      next if cleanup_schedule.blank?

      cleanup_schedule.update!(status: :running)
      cleanup_schedule
    end
  end
end
