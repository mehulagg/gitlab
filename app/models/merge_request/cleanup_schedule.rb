# frozen_string_literal: true

class MergeRequest::CleanupSchedule < ApplicationRecord
  belongs_to :merge_request, inverse_of: :cleanup_schedule
end
