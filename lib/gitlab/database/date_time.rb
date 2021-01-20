# frozen_string_literal: true

module Gitlab
  module Database
    module DateTime
      # Find the first of the `end_time_attrs` that isn't `NULL`. Subtract from it
      # the first of the `start_time_attrs` that isn't NULL. `SELECT` the resulting interval
      # along with an alias specified by the `as` parameter.
      #
      # Note: the interval is returned as an INTERVAL type.
      def subtract_datetimes(query_so_far, start_time_attrs, end_time_attrs, as)
        diff_fn = subtract_datetimes_diff(query_so_far, start_time_attrs, end_time_attrs)

        query_so_far.project(diff_fn.as(as))
      end

      def subtract_datetimes_diff(query_so_far, start_time_attrs, end_time_attrs)
        Arel::Nodes::Subtraction.new(
          Arel::Nodes::NamedFunction.new("COALESCE", Array.wrap(end_time_attrs)),
          Arel::Nodes::NamedFunction.new("COALESCE", Array.wrap(start_time_attrs))
        )
      end

      # Wraps column into DATE and TIMEZONE Postgres functions
      #
      # @example SQL query fragment
      #   DATE(TIMEZONE('UTC', column))
      #
      # @param column name of the column or attribute to be wrapped in DATE and TIMEZONE functions
      # @return [Arel::Nodes::NamedFunction] SQL query fragment
      def self.to_utc_date(column)
        column = Arel.sql(column) if column.is_a?(String)
        locked_timezone = Arel::Nodes::NamedFunction.new('TIMEZONE', [Arel.sql("'UTC'"), column])
        Arel::Nodes::NamedFunction.new('DATE', [locked_timezone])
      end
    end
  end
end
