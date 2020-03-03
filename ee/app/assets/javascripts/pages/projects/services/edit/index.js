import PrometheusMetrics from 'ee/prometheus_metrics/prometheus_metrics';
import PrometheusAlerts from '~/prometheus_alerts';
import IntegrationSettingsForm from '~/integrations/integration_settings_form';
import initAlertsSettings from '~/alerts_service_settings';

document.addEventListener('DOMContentLoaded', () => {
  const integrationSettingsForm = new IntegrationSettingsForm('.js-integration-settings-form');
  integrationSettingsForm.init();

  const prometheusSettingsWrapper = document.querySelector('.js-prometheus-metrics-monitoring');
  if (prometheusSettingsWrapper) {
    const prometheusMetrics = new PrometheusMetrics('.js-prometheus-metrics-monitoring');
    if (prometheusMetrics.isServiceActive) {
      prometheusMetrics.loadActiveCustomMetrics();
    } else {
      prometheusMetrics.setNoIntegrationActiveState();
    }
  }

  PrometheusAlerts();
  initAlertsSettings(document.querySelector('.js-alerts-service-settings'));
});
