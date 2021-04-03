# frozen_string_literal: true

module Vulnerabilities
  class HistoricalStatistic < ApplicationRecord
    include EachBatch

    self.table_name = 'vulnerability_historical_statistics'

    belongs_to :project, optional: false

    validates :date, presence: true
    validates :letter_grade, presence: true
    validates :total, numericality: { greater_than_or_equal_to: 0 }
    validates :critical, numericality: { greater_than_or_equal_to: 0 }
    validates :high, numericality: { greater_than_or_equal_to: 0 }
    validates :medium, numericality: { greater_than_or_equal_to: 0 }
    validates :low, numericality: { greater_than_or_equal_to: 0 }
    validates :unknown, numericality: { greater_than_or_equal_to: 0 }
    validates :info, numericality: { greater_than_or_equal_to: 0 }

    enum letter_grade: Vulnerabilities::Statistic.letter_grades

    scope :older_than, ->(days:) { where('"vulnerability_historical_statistics"."date" < now() - interval ?', "#{days} days") }
    scope :between_dates, -> (start_date, end_date) { where(arel_table[:date].between(start_date..end_date)) }
    scope :for_project, -> (project) { where(project: project) }
    scope :aggregated_by_date, -> do
      select(
        arel_table[:date],
        arel_table[:total].sum.as('total'),
        *::Enums::Vulnerability.severity_levels.map { |severity, _| arel_table[severity].sum.as(severity.to_s) }
      )
    end
    scope :grouped_by_date, -> (sort = :asc) do
      group(:date)
        .order(date: sort)
    end
  end
end
