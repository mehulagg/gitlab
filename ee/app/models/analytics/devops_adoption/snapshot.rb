# frozen_string_literal: true

class Analytics::DevopsAdoption::Snapshot < ApplicationRecord
  belongs_to :segment, inverse_of: :snapshots

  validates :segment, presence: true
  validates :recorded_at, presence: true
  validates :end_time, presence: true
  validates :issue_opened, inclusion: { in: [true, false] }
  validates :merge_request_opened, inclusion: { in: [true, false] }
  validates :merge_request_approved, inclusion: { in: [true, false] }
  validates :runner_configured, inclusion: { in: [true, false] }
  validates :pipeline_succeeded, inclusion: { in: [true, false] }
  validates :deploy_succeeded, inclusion: { in: [true, false] }
  validates :security_scan_succeeded, inclusion: { in: [true, false] }

  scope :latest_snapshot_for_segment_ids, -> (ids) do
    inner_select = model
      .default_scoped
      .distinct
      .select("FIRST_VALUE(id) OVER (PARTITION BY segment_id ORDER BY end_time DESC) as id")
      .where(segment_id: ids)

    joins("INNER JOIN (#{inner_select.to_sql}) latest_snapshots ON latest_snapshots.id = analytics_devops_adoption_snapshots.id")
  end

  def start_time
    end_time.beginning_of_month
  end
end
