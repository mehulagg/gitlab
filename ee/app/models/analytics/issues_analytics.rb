# frozen_string_literal: true

# Gathers issues stats per month returning a hash
# with the format: {"2017-12"=>{"created" => 5, "closed" => 3, "accumulated_open" => 18}, ...}
class Analytics::IssuesAnalytics
  attr_reader :issuables, :start_date, :months_back

  DATE_FORMAT = "%Y-%m".freeze

  def initialize(issuables:, months_back: nil)
    @issuables = issuables
    @months_back = months_back.present? ? (months_back.to_i - 1) : 12
    @start_date = @months_back.months.ago.beginning_of_month.to_date
  end

  def monthly_counters
    observation_months.each_with_object({}) do |month, result|
      result[month.strftime(DATE_FORMAT)] = counters(month: month)
    end
  end

  private

  attr_reader :created, :closed

  def observation_months
    @observation_months ||= (0..months_back).map do |offset|
      start_date + offset.months
    end
  end

  def counters(month:)
    load_created!
    load_closed!

    {
      created: created[month],
      closed: closed[month],
      accumulated_open: accumulated_open(month)
    }
  end

  def load_created!
    @created ||= load_monthly_info_on(field: 'created_at')
  end

  def load_closed!
    @closed ||= load_monthly_info_on(field: 'closed_at')
  end

  def load_monthly_info_on(field:)
    counters_stats = issuables.reorder(nil)
      .select("date_trunc('month', #{field})::date as month, count(*) as counter").group('month')

    result = counters_stats.map do |group|
      [group['month'], group['counter']]
    end.to_h

    observation_months.each do |month|
      result[month] ||= 0
    end

    result
  end

  def accumulated_open(month)
    calculate_accumulated_open!(month)
    @accumulated_open[month]
  end

  def calculate_accumulated_open!(month)
    @accumulated_open ||= {}
    @accumulated_open[month] ||= begin
      base = month == start_date ? initial_accumulated_open : accumulated_open(month - 1.month)

      base + created[month] - closed[month]
    end
  end

  def initial_accumulated_open
    @initial_accumulated_open ||= issuables.opened.where('created_at < ?', start_date).reorder(nil).count
  end
end
