# frozen_string_literal: true

class IngressModsecurityCounterMetricsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext
  include ExclusiveLeaseGuard

  feature_category :web_firewall

  worker_has_external_dependencies!

  LEASE_TIMEOUT = 1.hour

  def perform
    return unless Feature.enabled?(:usage_ingress_modsecurity_counter, default_enabled: true)

    try_obtain_lease do
      cluster_app_metrics = EE::Security::IngressModsecurityUsageService.new.execute

      Gitlab::UsageDataCounters::IngressModsecurityCounter.add(
        cluster_app_metrics[:statistics_unavailable],
        cluster_app_metrics[:packets_processed],
        cluster_app_metrics[:packets_anomalous]
      )
    end
  end

  private

  def lease_timeout
    LEASE_TIMEOUT
  end

  def lease_release?
    false
  end
end
