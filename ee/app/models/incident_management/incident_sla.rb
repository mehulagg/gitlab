# frozen_string_literal: true

module IncidentManagement
  class IncidentSla < ApplicationRecord
    self.primary_key = :issue_id

    belongs_to :issue, optional: false
    validates :issue, presence: true
    validates :due_at, presence: true
  end
end
