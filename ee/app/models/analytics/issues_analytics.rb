# frozen_string_literal: true

# Gathers issues stats per month returning a hash
# with the format: {"2017-12"=>{"created" => 5, "closed" => 3, "accumulated_open" => 18}, ...}
class Analytics::IssuesAnalytics
  attr_reader :issues, :start_date, :months_back

  DATE_FORMAT = "%Y-%m"

  def initialize(issues:, months_back: nil)
    @issues = issues
    @months_back = months_back.present? ? (months_back.to_i - 1) : 12
    @start_date = @months_back.months.ago.beginning_of_month.to_date
  end

  def monthly_counters
    observation_months.each_with_object({}) do |month, result|
      result[month.strftime(DATE_FORMAT)] = counters(month: month)
    end
  end

  private

  def observation_months
    @observation_months ||= (0..months_back).map do |offset|
      start_date + offset.months
    end
  end

  def counters(month:)
    {
      created: created[month],
      closed: closed[month],
      accumulated_open: accumulated_open(month)
    }
  end

  def created
    @created ||= load_monthly_info_on(field: 'created_at')
  end

  def closed
    @closed ||= load_monthly_info_on(field: 'closed_at')
  end

  def load_monthly_info_on(field:)
    counters_stats = issues
      .reorder(nil)
      .where(Issue.arel_table[field].gteq(start_date))
      .group('month')
      .pluck(Arel.sql("date_trunc('month', issues.#{field})::date as month, count(*) as counter"))
      .to_h

    observation_months.each do |month|
      counters_stats[month] ||= 0
    end

    counters_stats
  end

  def accumulated_open(month)
    @accumulated_open ||= {}
    @accumulated_open[month] ||= begin
      base = month == start_date ? initial_accumulated_open : accumulated_open(month - 1.month)

      base + created[month] - closed[month]
    end
  end

  def initial_accumulated_open
    @initial_accumulated_open ||= issues
      .opened
      .where(Issue.arel_table['created_at'].lt(start_date))
      .reorder(nil)
      .count
  end
end
