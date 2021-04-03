# frozen_string_literal: true

module Geo
  class ReplicationToggleRequestService < RequestService
    include Gitlab::Geo::LogHelpers

    attr_reader :enabled

    def initialize(enabled:)
      @enabled = enabled
    end

    def execute
      return false unless primary_node.present?

      success = super(primary_node_api_url, payload(enabled), method: Net::HTTP::Put)
      Gitlab::Geo.expire_cache! if success

      success
    end

    def payload(enabled)
      { enabled: enabled }
    end

    def primary_node_api_url
      primary_node&.node_api_url(Gitlab::Geo.current_node)
    end
  end
end
