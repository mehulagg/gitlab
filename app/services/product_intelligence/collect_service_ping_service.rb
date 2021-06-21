# frozen_string_literal: true

module ProductIntelligence
  class CollectServicePingService
    def execute
      return {} unless ::License.current.usage_ping? || ::Gitlab::CurrentSettings.usage_ping_enabled?

      filtered_usage_data(%w[Standard])
    end

    private

    def filtered_usage_data(allowed_categories)
      ::Gitlab::UsageData.data
    end
  end
end
