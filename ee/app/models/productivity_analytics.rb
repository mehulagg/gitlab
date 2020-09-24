# frozen_string_literal: true

class ProductivityAnalytics
  attr_reader :merge_requests, :sort

  METRIC_COLUMNS = {
    'days_to_merge' => "DATE_PART('day', merge_request_metrics.merged_at - merge_requests.created_at)",
    'time_to_first_comment' => "DATE_PART('day', merge_request_metrics.first_comment_at - merge_requests.created_at)*24+DATE_PART('hour', merge_request_metrics.first_comment_at - merge_requests.created_at)",
    'time_to_last_commit' => "DATE_PART('day', merge_request_metrics.last_commit_at - merge_request_metrics.first_comment_at)*24+DATE_PART('hour', merge_request_metrics.last_commit_at - merge_request_metrics.first_comment_at)",
    'time_to_merge' => "DATE_PART('day', merge_request_metrics.merged_at - merge_request_metrics.last_commit_at)*24+DATE_PART('hour', merge_request_metrics.merged_at - merge_request_metrics.last_commit_at)",
    'commits_count' => 'commits_count',
    'loc_per_commit' => '(diff_size/commits_count)',
    'files_touched' => 'modified_paths_size'
  }.freeze

  METRIC_TYPES = METRIC_COLUMNS.keys.freeze
  DEFAULT_TYPE = 'days_to_merge'.freeze

  def self.start_date
    ApplicationSetting.current&.productivity_analytics_start_date
  end

  def initialize(merge_requests:, sort: nil)
    @merge_requests = merge_requests.joins(:metrics)
    @sort = sort
  end

  def histogram_data(type:)
    return unless column = METRIC_COLUMNS[type]

    histogram_query(column).map do |data|
      [data[:metric]&.to_i, data[:mr_count]]
    end.to_h
  end

  def scatterplot_data(type:)
    return unless column = METRIC_COLUMNS[type]

    scatterplot_query(column).map do |data|
      [data.id, { metric: data[:metric], merged_at: data[:merged_at] }]
    end.to_h
  end

  def merge_requests_extended
    columns = METRIC_COLUMNS.map do |type, column|
      Arel::Nodes::As.new(Arel.sql(column), Arel.sql(type)).to_sql
    end
    columns.unshift(MergeRequest.arel_table[Arel.star])

    MergeRequest.joins(:metrics).select(columns).where(id: merge_requests).order(sorting)
  end

  private

  def histogram_query(column)
    MergeRequest::Metrics.joins(:merge_request)
      .where(merge_request_id: merge_requests)
      .select("#{column} as metric, count(*) as mr_count")
      .group(column)
  end

  def scatterplot_query(column)
    MergeRequest::Metrics.joins(:merge_request).where(merge_request_id: merge_requests)
      .select("#{column} as metric, merge_requests.id, merge_request_metrics.merged_at")
      .order("merge_request_metrics.merged_at ASC, id ASC")
  end

  def sorting
    return default_sorting unless sort

    column, direction = sort.split(/_(asc|desc)$/i)

    return default_sorting unless column.in?(METRIC_TYPES)

    Arel.sql("#{column} #{direction}")
  end

  def default_sorting
    { id: :desc }
  end
end
