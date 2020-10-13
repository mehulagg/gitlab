# frozen_string_literal: true

class ProductivityAnalyticsFinder < MergeRequestsFinder
  extend ::Gitlab::Utils::Override

  def self.array_params
    super.merge(days_to_merge: [])
  end

  def filter_items(_items)
    by_days_to_merge(super)
  end

  private

  # rubocop: disable CodeReuse/ActiveRecord
  def by_days_to_merge(items)
    return items unless params[:days_to_merge].present?

    items.joins(:metrics).where("#{days_to_merge_column} IN (?)", params[:days_to_merge].flatten.map(&:to_i))
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def days_to_merge_column
    "date_part('day',merge_request_metrics.merged_at - merge_requests.created_at)"
  end

  # originated from from MergedAtFilter
  override :merged_after
  def merged_after
    @merged_after ||= [super, ProductivityAnalytics.start_date].compact.max
  end
end
