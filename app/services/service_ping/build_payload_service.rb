# frozen_string_literal: true

module ServicePing
  class BuildPayloadService
    STANDARD_CATEGORY = 'Standard'
    SUBSCRIPTION_CATEGORY = 'Subscription'
    OPTIONAL_CATEGORY = 'Optional'
    OPERATIONAL_CATEGORY = 'Operational'
    EMPTY_PAYLOAD = {}.freeze

    def execute
      return EMPTY_PAYLOAD if User.single_user&.requires_usage_stats_consent?
      return EMPTY_PAYLOAD unless product_intelligence_enabled?

      filtered_usage_data
    end

    private

    def product_intelligence_enabled?
      ::Gitlab::CurrentSettings.usage_ping_enabled?
    end

    def filtered_usage_data(payload = raw_payload, parents = [])
      payload.keep_if do |label, node|
        if leaf?(node)
          permitted_categories.include?(metric_category(label, parents))
        else
          filtered_usage_data(node, parents.dup << label)
        end
      end
    end

    def metric_category(key, parent_keys)
      key_path = parent_keys.dup.append(key).join('.')
      metric_definitions[key_path]&.attributes&.fetch(:data_category, OPTIONAL_CATEGORY)
    end

    def permitted_categories
      @permitted_categories ||= filter_permitted_categories
    end

    def filter_permitted_categories
      return [] unless ::Gitlab::CurrentSettings.usage_ping_enabled?

      [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY, OPTIONAL_CATEGORY, OPERATIONAL_CATEGORY]
    end

    def raw_payload
      @raw_payload ||= ::Gitlab::UsageData.data(force_refresh: true)
    end

    def metric_definitions
      @metric_definitions ||= Gitlab::Usage::MetricDefinition.definitions
    end

    def leaf?(node)
      !node.is_a?(Hash)
    end
  end
end

ServicePing::BuildPayloadService.prepend_mod_with('ServicePing::BuildPayloadService')
