# frozen_string_literal: true

class Analytics::DevopsAdoption::Snapshot < ApplicationRecord
  include IgnorableColumns

  belongs_to :namespace

  has_many :enabled_namespaces, foreign_key: :namespace_id, primary_key: :namespace_id

  validates :namespace, presence: true
  validates :recorded_at, presence: true
  validates :end_time, presence: true
  validates :issue_opened, inclusion: { in: [true, false] }
  validates :merge_request_opened, inclusion: { in: [true, false] }
  validates :merge_request_approved, inclusion: { in: [true, false] }
  validates :runner_configured, inclusion: { in: [true, false] }
  validates :pipeline_succeeded, inclusion: { in: [true, false] }
  validates :deploy_succeeded, inclusion: { in: [true, false] }
  validates :security_scan_succeeded, inclusion: { in: [true, false] }
  validates :total_projects_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :code_owners_used_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  ignore_column :segment_id, remove_with: '14.2', remove_after: '2021-07-22'

  scope :latest_snapshot_for_namespace_ids, -> (ids) do
    inner_select = model
      .default_scoped
      .distinct
      .select("FIRST_VALUE(id) OVER (PARTITION BY namespace_id ORDER BY end_time DESC) as id")
      .where(namespace_id: ids)

    joins("INNER JOIN (#{inner_select.to_sql}) latest_snapshots ON latest_snapshots.id = analytics_devops_adoption_snapshots.id")
  end

  scope :for_month, -> (month_date) { where(end_time: month_date.end_of_month) }
  scope :not_finalized, -> { where(arel_table[:recorded_at].lteq(arel_table[:end_time])) }
  scope :by_end_time, -> { order(end_time: :desc) }

  scope :for_timespan, -> (after: nil, before: nil) {
    result = self
    result = result.where(arel_table[:end_time].gteq(after)) if after
    result = result.where(arel_table[:end_time].lteq(before)) if before
    result
  }

  def start_time
    end_time.beginning_of_month
  end

end
