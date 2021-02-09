# frozen_string_literal: true

# This class is used to store usage data on a secondary for transmission
# to the primary during a status update.
class Geo::SecondaryUsageData < Geo::TrackingBase
  include JsonbStoreAccessor
  # Eventually, this we'll find a way to auto-load this
  # from the metric yaml files that include something
  # like `run_on_secondary: true`, but for now we'll
  # just enumerate them.
  RESOURCE_DATA_FIELDS = %i(
    git_fetch_event_count
  ).freeze

  jsonb_store_accessor :data, RESOURCE_DATA_FIELDS
end
