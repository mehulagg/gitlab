# frozen_string_literal: true

module Resolvers
  class SecurityReportSummaryResolver < BaseResolver
    type Types::SecurityReportSummaryType, null: true

    alias_method :pipeline, :object

    def resolve(lookahead:)
      Security::ReportSummaryService.new(
        pipeline,
        selection_information(lookahead)
      ).execute
    end

    private

    def selection_information(lookahead)
      lookahead.selections.each_with_object({}) do |report_type, response|
        response[report_type.name.to_sym] = report_type.selections.map(&:name)
      end
    end
  end
end
