# frozen_string_literal: true

module Geo
  class NodeStatusRequestService < RequestService
    include Gitlab::Geo::LogHelpers

    attr_reader :status

    def initialize(status)
      @status = status
    end

    def execute
      return false unless primary_node.present?

      super(primary_status_url, payload(status))
    end

    private

    def primary_status_url
      primary_node&.status_url
    end

    def payload(status)
      # RESOURCE_STATUS_FIELDS is excluded since that data would be duplicated
      # in the payload as top-level attributes as well attributes nested in the
      # new status field. We can remove this exclusion when we remove those
      # deprecated columns from the geo_node_statuses table.
      excluded_keys = GeoNodeStatus::RESOURCE_STATUS_FIELDS + ['id']

      status.attributes.except(*excluded_keys)
    end
  end
end
