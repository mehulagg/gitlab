# frozen_string_literal: true

module Resolvers
  module Ci
    class LeadTimeResolver < BaseResolver
      type [::Types::Ci::AnalyticsDataPointType], null: true

      argument :from, ::Types::DateType,
              required: true,
              description: 'Datetime to start from, inclusive.'
      argument :to, ::Types::DateType,
              required: false,
              description: 'Datetime to end at, exclusive.'
      argument :interval, ::Types::Ci::AnalyticsIntervalEnum,
              required: false,
              default_value: 'all',
              description: 'Interval to roll-up data by.'

      alias_method :project, :object

      def resolve(**args)
        result = ::Analytics::MergeRequests::LeadTime::AggregateService
          .new(container: project,
                current_user: current_user,
                params: args)
          .execute

        unless result[:status] == :success
          raise(result[:message])
        end

        # TODO: Present this using a presenter, similar to
        # how the REST API does this. Right now the "from" field
        # isn't correctly formatted.
        result[:lead_times]
      end
    end
  end
end
