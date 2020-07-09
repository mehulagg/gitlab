# frozen_string_literal: true

class ProductAnalyticsEvent < ApplicationRecord
  self.table_name = 'product_analytics_events_experimental'

  # Ignore that the partition key :project_id is part of the formal primary key
  self.primary_key = :id

  belongs_to :project

  # There is no default Rails timestamps in the table.
  # collector_tstamp is a timestamp when a collector recorded an event.
  scope :order_by_time, -> { order(collector_tstamp: :desc) }

  # If we decide to change this scope to use date_trunc('day', collector_tstamp),
  # we should remember that a btree index on collector_tstamp will be no longer effective.
  scope :timerange, ->(duration, today = Time.zone.today) {
    where('collector_tstamp BETWEEN ? AND ? ', today - duration + 1, today + 1)
  }

  class << self
    def count_by_graph(graph, days)
      group(graph).timerange(days).count
    end

    def count_by_day_and_graph(graph, days)
      group("DATE_TRUNC('day', #{graph})").timerange(days).count
    end
  end
end
