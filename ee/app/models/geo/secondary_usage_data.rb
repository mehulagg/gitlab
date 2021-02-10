# frozen_string_literal: true

# This class is used to store usage data on a secondary for transmission
# to the primary during a status update.
class Geo::SecondaryUsageData < Geo::TrackingBase
  include JsonbStoreAccessor
  include Gitlab::Utils::UsageData

  # Eventually, this we'll find a way to auto-load this
  # from the metric yaml files that include something
  # like `run_on_secondary: true`, but for now we'll
  # just enumerate them.
  RESOURCE_DATA_FIELDS = %i(
    git_fetch_event_weekly_count
  ).freeze

  jsonb_store_accessor :data, RESOURCE_DATA_FIELDS

  def update_metrics
    self.git_fetch_event_weekly_count = with_prometheus_client do |client|
      client.query('round(sum(increase(grpc_server_handled_total{grpc_method=~"SSHUploadPack|PostUploadPack"}[7d])))')
    end
  end
end
