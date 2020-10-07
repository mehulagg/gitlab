# frozen_string_literal: true

module IncidentManagement
  class IncidentSla < ApplicationRecord
    self.primary_key = :issue_id

    belongs_to :issue, optional: false
    validates :due_at, presence: true

    scope :exceeded, -> { joins(:issue).merge(Issue.opened).where('due_at < ?', Time.current) }
  end
end
