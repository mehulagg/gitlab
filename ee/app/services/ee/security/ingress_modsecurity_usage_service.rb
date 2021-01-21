# frozen_string_literal: true

module EE
  module Security
    ##
    # This service measures usage of the Modsecurity Web Application Firewall across the entire
    # instance's deployed environments.
    #
    ##
    class IngressModsecurityUsageService
      BATCH_SIZE = 1

      def initialize
        @statistics_unavailable_count = 0
        @packets_processed_count = 0
        @packets_anomalous_count = 0
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def execute
        clusters_with_enabled_modsecurity.find_each(batch_size: BATCH_SIZE) do |cluster|
          cluster.environments.each do |environment|
            result = anomaly_results_for_cluster_and_environment(cluster, environment)
            if result.nil?
              @statistics_unavailable_count += 1
            else
              @packets_processed_count += result[:total_traffic]
              @packets_anomalous_count += result[:total_anomalous_traffic]
            end
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        {
          statistics_unavailable: @statistics_unavailable_count.to_i,
          packets_processed: @packets_processed_count.to_i,
          packets_anomalous: @packets_anomalous_count.to_i
        }
      end

      private

      def anomaly_results_for_cluster_and_environment(cluster, environment)
        # As defined in config/initializers/1_settings.rb#562, IngressModsecurityCounterMetricsWorker will be executed
        # once a week. That is why when we are collecting data from clusters we are querying for the last 7 days.
        ::Security::WafAnomalySummaryService
          .new(environment: environment, cluster: cluster, from: 7.days.ago.iso8601, options: { timeout: 10 })
          .execute(totals_only: true)
      rescue => e
        ::Gitlab::ErrorTracking.track_exception(e, environment_id: environment&.id, cluster_id: cluster&.id)
        nil
      end

      def clusters_with_enabled_modsecurity
        ::Clusters::Cluster
          .with_enabled_modsecurity
          .with_available_elasticstack
          .distinct_with_deployed_environments
          .preload_elasticstack
          .preload_environments
      end
    end
  end
end
