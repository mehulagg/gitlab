# frozen_string_literal: true

class MergeRequest::CleanupSchedule < ApplicationRecord
  belongs_to :merge_request, inverse_of: :cleanup_schedule

  validates :scheduled_at, presence: true

  def self.scheduled(limit)
    where('completed_at IS NULL AND scheduled_at <= ?', Time.current)
      .order('scheduled_at DESC')
      .limit(limit)
  end
end
