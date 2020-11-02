# frozen_string_literal: true

module EE
  module Types
    module Ci
      module PipelineType
        extend ActiveSupport::Concern

        prepended do
          field :security_report_summary,
            ::Types::SecurityReportSummaryType,
            null: true,
            extras: [:lookahead],
            description: 'Vulnerability and scanned resource counts for each security scanner of the pipeline',
            resolver: ::Resolvers::SecurityReportSummaryResolver

          field :jobs,
            ::Types::Ci::JobType.connection_type,
            null: true,
            description: 'Jobs belonging to the pipeline',
            resolver: ::Resolvers::Ci::JobsResolver
        end
      end
    end
  end
end
