# frozen_string_literal: true

# Gather the number of issuables created by month returning
# a hash with the format: {"2017-12"=>2, "2018-01"=>2, "2018-03"=>1}
#
# By default it creates the hash only for the last 12 months including the current month, but it accepts
# a parameter to get issuables for n months back.
#
# This class should be removed together with feature flag :new_issues_analytics_chart_data when
# :new_issues_analytics_chart_data becomes default behavior
class IssuablesAnalytics
  include Gitlab::Utils::StrongMemoize

  attr_reader :issuables, :start_date, :end_date, :months_back

  DATE_FORMAT = "%Y-%m"

  def initialize(issuables:, months_back: nil)
    @issuables = issuables
    @months_back = months_back.to_i - 1 if months_back.present?
    @months_back ||= 12
    @start_date = @months_back.months.ago.beginning_of_month.to_date
    @end_date = Date.today
  end

  def data
    start_date_to_end_date = start_date.upto(end_date).to_a

    start_date_to_end_date.each_with_object({}) do |date, data_hash|
      date = date.strftime(DATE_FORMAT)
      data_hash[date] = issues_created_at_dates.count(date) || 0
    end
  end

  private

  def issues_created_at_dates
    strong_memoize(:issues_created_at_dates) do
      issuables
        .reorder(nil)
        .where('issues.created_at >= ?', months_back.months.ago.beginning_of_month)
        .pluck('issues.created_at')
        .map { |date| date.strftime(DATE_FORMAT) }
    end
  end
end
