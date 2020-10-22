# frozen_string_literal: true

module Vulnerabilities
  module Statistics
    class UpdateService
      LETTER_GRADE_SQL = <<~SQL
        CASE
        WHEN TARGET.critical + EXCLUDED.critical > 0 THEN
          #{Statistic.letter_grades[:f]}
        WHEN TARGET.high + TARGET.unknown + EXCLUDED.high + EXCLUDED.unknown > 0 THEN
          #{Statistic.letter_grades[:d]}
        WHEN TARGET.medium + EXCLUDED.medium > 0 THEN
          #{Statistic.letter_grades[:c]}
        WHEN TARGET.low + EXCLUDED.low > 0 THEN
          #{Statistic.letter_grades[:b]}
        ELSE
          #{Statistic.letter_grades[:a]}
        END
      SQL

      UPSERT_SQL = <<~SQL
        INSERT INTO #{Statistic.table_name} AS target (project_id, %{insert_attributes}, letter_grade, created_at, updated_at)
          VALUES (%{project_id}, %{insert_values}, %{letter_grade}, now(), now())
        ON CONFLICT (project_id)
          DO UPDATE SET
            %{update_values}, letter_grade = (#{LETTER_GRADE_SQL}), updated_at = now()
      SQL

      def self.update_for(vulnerability)
        new(vulnerability).execute
      end

      def initialize(vulnerability)
        self.vulnerability = vulnerability
      end

      def execute
        return unless stat_diff.update_required?

        connection.execute(upsert_sql)
      end

      private

      attr_accessor :vulnerability

      delegate :connection, to: Statistic, private: true
      delegate :quote, :quote_column_name, to: :connection, private: true

      def stat_diff
        @stat_diff ||= vulnerability.stat_diff
      end

      def upsert_sql
        format(
          UPSERT_SQL,
          project_id: stat_diff.project_id,
          insert_attributes: insert_attributes,
          insert_values: insert_values,
          letter_grade: letter_grade,
          update_values: update_values
        )
      end

      def insert_attributes
        stat_diff.changed_attributes.map { |attribute| quote_column_name(attribute) }.join(', ')
      end

      def insert_values
        stat_diff.changed_values.map { |value| quote(value) }.join(', ')
      end

      def letter_grade
        quote(Statistic.letter_grade_for(stat_diff.changes))
      end

      def update_values
        stat_diff.changes.map do |attribute, value|
          column_name = quote_column_name(attribute)
          quoted_value = quote(value)

          "#{column_name} = GREATEST(TARGET.#{column_name} + #{quoted_value}, 0)"
        end.join(', ')
      end
    end
  end
end
