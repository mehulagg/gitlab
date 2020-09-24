# frozen_string_literal: true

module Geo
  module RepositoryReplicatorStrategy
    extend ActiveSupport::Concern

    include Delay
    include Gitlab::Geo::LogHelpers

    included do
      event :updated
      event :deleted
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_updated(**params)
      # not implemented yet
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_deleted(**params)
      # not implemented yet
    end
  end
end
