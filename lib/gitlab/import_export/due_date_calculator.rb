# frozen_string_literal: true

module Gitlab
  module ImportExport
    class DueDateCalculator
      include Gitlab::Utils::StrongMemoize

      def initialize(due_dates)
        @due_dates = due_dates
      end

      def median_time
        strong_memoize(:median_time) do
          next if @due_dates.empty?

          array = @due_dates.map{ |date| date.to_time.to_f }
          sorted = array.sort
          len = sorted.length

          Time.zone.at((sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0)
        end
      end

      def calculate(due_date)
        return due_date unless median_time && median_time < Time.current

        due_date + (Time.current - median_time).seconds
      end
    end
  end
end
