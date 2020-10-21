# frozen_string_literal: true

module Types
  module Security
    class ReportTypeEnum < BaseEnum
      ::Security::SecurityJobsFinder.allowed_job_types.each do |report_type|
        value report_type.upcase, value: report_type, description: "#{report_type.to_s.capitalize.humanize} scan report"
      end
    end
  end
end
