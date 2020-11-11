# frozen_string_literal: true

class Analytics::DevopsAdoption::Snapshot < ApplicationRecord
  belongs_to :segment, inverse_of: :snapshots

  validates :segment, presence: true
  validates :recorded_at, presence: true
  validates :issue_opened, inclusion: { in: [true, false] }
  validates :merge_request_opened, inclusion: { in: [true, false] }
  validates :merge_request_approved, inclusion: { in: [true, false] }
  validates :runner_configured, inclusion: { in: [true, false] }
  validates :pipeline_succeeded, inclusion: { in: [true, false] }
  validates :deploy_succeeded, inclusion: { in: [true, false] }
  validates :security_scan_succeeded, inclusion: { in: [true, false] }
end
