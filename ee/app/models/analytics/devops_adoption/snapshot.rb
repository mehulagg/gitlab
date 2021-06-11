# frozen_string_literal: true

class Analytics::DevopsAdoption::Snapshot < ApplicationRecord
  include IgnorableColumns

  BOOLEAN_METRICS = [
    :issue_opened,
    :merge_request_opened,
    :merge_request_approved,
    :runner_configured,
    :pipeline_succeeded,
    :deploy_succeeded,
    :security_scan_succeeded
  ].freeze

  NUMERIC_METRICS = [
    :code_owners_used_count,
    :sast_enabled_count,
    :dast_enabled_count,
    :total_projects_count
  ].freeze

  ADOPTION_METRICS = BOOLEAN_METRICS + NUMERIC_METRICS

  belongs_to :namespace

  has_many :enabled_namespaces, foreign_key: :namespace_id, primary_key: :namespace_id

  validates :namespace, presence: true
  validates :recorded_at, presence: true
  validates :end_time, presence: true
  validates *BOOLEAN_METRICS, inclusion: { in: [true, false] }
  validates *NUMERIC_METRICS, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

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

  def start_time
    end_time.beginning_of_month
  end
end
