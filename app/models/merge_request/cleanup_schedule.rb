# frozen_string_literal: true

class MergeRequest::CleanupSchedule < ApplicationRecord
  belongs_to :merge_request, inverse_of: :cleanup_schedule

  validates :scheduled_at, presence: true
end
