# frozen_string_literal: true

class IssuableSla < ApplicationRecord
  include EachBatch

  belongs_to :issue, optional: false
  validates :due_at, presence: true

  scope :exceeded_for_issues, -> { joins(:issue).merge(Issue.opened).where('due_at < ?', Time.current) }
  scope :exceeded_label_not_applied, -> { where(label_applied: false) }
end
