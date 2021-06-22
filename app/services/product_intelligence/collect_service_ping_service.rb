# frozen_string_literal: true

module ProductIntelligence
  class CollectServicePingService
    def execute
      return {} unless ::License.current&.usage_ping? || ::Gitlab::CurrentSettings.usage_ping_enabled?

      filtered_usage_data(required_categories)
    end

    private

    def filtered_usage_data(allowed_categories, payload = raw_payload, parent_keys = [])
      payload.keep_if do |key, value|
        if value.kind_of?(Hash)
          filtered_usage_data(allowed_categories, value, parent_keys.dup << key)
          true
        else
          key_path = parent_keys.dup.append(key).join('.')
          metric_data_category = metric_definitions[key_path]&.attributes&.fetch('data_category', nil)
          allowed_categories.include?(metric_data_category)
        end
      end
    end

    def required_categories
      optional_enabled = ::Gitlab::CurrentSettings.usage_ping_enabled?
      license_present = ::License.current.present?
      operational_enabled = ::License.current&.usage_ping?
      all_categories = %w[Standard Subscription Optional Operational]

      return all_categories if !license_present && optional_enabled

      return all_categories if optional_enabled && operational_enabled

      return %w[Standard Subscription Optional] if optional_enabled && !operational_enabled

      return %w[Standard Subscription Operational] if !optional_enabled && operational_enabled

      []
    end

    def raw_payload
      @raw_payload ||= ::Gitlab::UsageData.data
    end

    def metric_definitions
      @metric_definitions ||= Gitlab::Usage::MetricDefinition.definitions
    end
  end
end
