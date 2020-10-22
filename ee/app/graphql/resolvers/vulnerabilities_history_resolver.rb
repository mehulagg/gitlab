# frozen_string_literal: true

module Resolvers
  class VulnerabilitiesHistoryResolver < VulnerabilitiesBaseResolver
    include Gitlab::Utils::StrongMemoize

    MAX_DAYS = ::Vulnerability::MAX_DAYS_OF_HISTORY

    type Types::VulnerabilitiesCountByDayAndSeverityType, null: true

    argument :start_date, GraphQL::Types::ISO8601Date, required: true,
              description: 'First day for which to fetch vulnerability history'

    argument :end_date, GraphQL::Types::ISO8601Date, required: true,
              description: 'Last day for which to fetch vulnerability history'

    def resolve(**args)
      return [] unless vulnerable

      start_date = args[:start_date]
      end_date = args[:end_date]
      days = end_date - start_date + 1

      if days > MAX_DAYS
        raise ::Vulnerability::TooManyDaysError, "Cannot fetch counts for more than #{MAX_DAYS} days"
      else
        vulnerable.vulnerabilities.counts_by_day_and_severity(start_date, end_date).to_a
      end
    end
  end
end
