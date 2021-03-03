# frozen_string_literal: true

# This class is used to store usage data on a secondary for transmission
# to the primary during a status update.
class Geo::SecondaryUsageData < Geo::TrackingBase
  # Eventually, we'll find a way to auto-load this
  # from the metric yaml files that include something
  # like `run_on_secondary: true`, but for now we'll
  # just enumerate them.
  PAYLOAD_COUNT_FIELDS = %w(
    git_fetch_event_count
  ).freeze

  store_accessor :payload, *PAYLOAD_COUNT_FIELDS
  validate :payload_schema_is_valid

  def payload_schema_is_valid
    payload.keys.each do |key|
      if PAYLOAD_COUNT_FIELDS.include?(key)
        errors.add(:payload, "payload[#{key}] must be a number") unless payload[key].nil? || payload[key].is_a?(Numeric)
      else
        errors.add(:payload, "unexpected key in payload - #{key}")
      end
    end
  end
end
