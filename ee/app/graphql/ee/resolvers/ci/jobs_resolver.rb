# frozen_string_literal: true

module EE
  module Resolvers
    module Ci
      module JobsResolver
        extend ::Gitlab::Utils::Override

        prepended do
          argument :security_report_types, [Types::Security::ReportTypeEnum],
                  required: false,
                  description: 'Filter jobs by the type of security report they produce'
        end

        override :resolve_with_lookahead
        def resolve_with_lookahead(security_report_types: [])
          if security_report_types.present?
            ::Security::SecurityJobsFinder.new(
              pipeline: pipeline,
              job_types: security_report_types
            ).execute
          else
            super
          end
        end
      end
    end
  end
end
