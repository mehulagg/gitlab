# frozen_string_literal: true

module Resolvers
  class ProjectMergeRequestsMeanTimeToMergeResolver < BaseResolver
    argument :from, Types::TimeType,
             required: false,
             description: 'From time'
    argument :to, Types::TimeType,
             required: false,
             description: 'To time'

    def resolve(from: 12.months.ago, to: DateTime.now)
      object.merge_requests
        .joins(:metrics)
        .where('merge_requests.created_at > ? AND merge_requests.created_at <= ?', from, to)
        .pluck(Arel.sql('EXTRACT(epoch FROM AVG(AGE(merge_request_metrics.merged_at, merge_requests.created_at)))'))
        .first
    end
  end
end
