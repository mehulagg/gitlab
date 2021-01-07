<script>
import { mapActions } from 'vuex';
import { GlAlert, GlEmptyState, GlIcon, GlLink, GlPopover, GlTabs, GlTab } from '@gitlab/ui';
import { s__ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import Alerts from './alerts/alerts.vue';
import ThreatMonitoringFilters from './threat_monitoring_filters.vue';
import ThreatMonitoringSection from './threat_monitoring_section.vue';
import NetworkPolicyList from './network_policy_list.vue';

export default {
  name: 'ThreatMonitoring',
  components: {
    GlAlert,
    GlEmptyState,
    GlIcon,
    GlLink,
    GlPopover,
    GlTabs,
    GlTab,
    Alerts,
    ThreatMonitoringFilters,
    ThreatMonitoringSection,
    NetworkPolicyList,
  },
  inject: ['documentationPath'],
  mixins: [glFeatureFlagsMixin()],
  props: {
    defaultEnvironmentId: {
      type: Number,
      required: true,
    },
    chartEmptyStateSvgPath: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    wafNoDataSvgPath: {
      type: String,
      required: true,
    },
    networkPolicyNoDataSvgPath: {
      type: String,
      required: true,
    },
    showUserCallout: {
      type: Boolean,
      required: true,
    },
    userCalloutId: {
      type: String,
      required: true,
    },
    userCalloutsPath: {
      type: String,
      required: true,
    },
    newPolicyPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showAlert: this.showUserCallout,

      // We require the project to have at least one available environment.
      // An invalid default environment id means there there are no available
      // environments, therefore infrastructure cannot be set up. A valid default
      // environment id only means that infrastructure *might* be set up.
      isSetUpMaybe: this.isValidEnvironmentId(this.defaultEnvironmentId),
    };
  },
  computed: {
    showAlertsTab() {
      return this.glFeatures.threatMonitoringAlerts;
    },
  },
  created() {
    if (this.isSetUpMaybe) {
      this.setCurrentEnvironmentId(this.defaultEnvironmentId);
      this.fetchEnvironments();
    }
  },
  methods: {
    ...mapActions('threatMonitoring', ['fetchEnvironments', 'setCurrentEnvironmentId']),
    isValidEnvironmentId(id) {
      return Number.isInteger(id) && id >= 0;
    },
    dismissAlert() {
      this.showAlert = false;

      axios.post(this.userCalloutsPath, {
        feature_name: this.userCalloutId,
      });
    },
  },
  chartEmptyStateDescription: s__(
    `ThreatMonitoring|While it's rare to have no traffic coming to your
    application, it can happen. In any event, we ask that you double check your
    settings to make sure you've set up the WAF correctly.`,
  ),
  wafChartEmptyStateDescription: s__(
    `ThreatMonitoring|The firewall is not installed or has been disabled. To view
     this data, ensure the web application firewall is installed and enabled for your cluster.`,
  ),
  networkPolicyChartEmptyStateDescription: s__(
    `ThreatMonitoring|Container Network Policies are not installed or have been disabled. To view
     this data, ensure your Network Policies are installed and enabled for your cluster.`,
  ),
  emptyStateDescription: s__(
    `ThreatMonitoring|To view this data, ensure you have configured an environment
    for this project and that at least one threat monitoring feature is enabled.`,
  ),
  alertText: s__(
    `ThreatMonitoring|The graph below is an overview of traffic coming to your
    application as tracked by the Web Application Firewall (WAF). View the docs
    for instructions on how to access the WAF logs to see what type of
    malicious traffic is trying to access your app. The docs link is also
    accessible by clicking the "?" icon next to the title below.`,
  ),
  helpPopoverText: s__('ThreatMonitoring|View documentation'),
};
</script>

<template>
  <gl-empty-state
    v-if="!isSetUpMaybe"
    ref="emptyState"
    :title="s__('ThreatMonitoring|No environments detected')"
    :description="$options.emptyStateDescription"
    :svg-path="emptyStateSvgPath"
    :primary-button-link="documentationPath"
    :primary-button-text="__('More information')"
  />

  <section v-else>
    <gl-alert
      v-if="showAlert"
      class="my-3"
      variant="info"
      :secondary-button-link="documentationPath"
      :secondary-button-text="__('View documentation')"
      @dismiss="dismissAlert"
    >
      {{ $options.alertText }}
    </gl-alert>
    <header class="my-3">
      <h2 class="h3 mb-1">
        {{ s__('ThreatMonitoring|Threat Monitoring') }}
        <gl-link
          ref="helpLink"
          target="_blank"
          :href="documentationPath"
          :aria-label="s__('ThreatMonitoring|Threat Monitoring help page link')"
        >
          <gl-icon name="question" />
        </gl-link>
        <gl-popover :target="() => $refs.helpLink" triggers="hover focus">
          {{ $options.helpPopoverText }}
        </gl-popover>
      </h2>
    </header>

    <gl-tabs>
      <gl-tab
        v-if="showAlertsTab"
        :title="s__('ThreatMonitoring|Alerts')"
        data-testid="threat-monitoring-alerts-tab"
      >
        <alerts />
      </gl-tab>
      <gl-tab ref="networkPolicyTab" :title="s__('ThreatMonitoring|Policies')">
        <network-policy-list
          :documentation-path="documentationPath"
          :new-policy-path="newPolicyPath"
        />
      </gl-tab>
      <gl-tab :title="s__('ThreatMonitoring|Statistics')">
        <threat-monitoring-filters />

        <threat-monitoring-section
          ref="wafSection"
          store-namespace="threatMonitoringWaf"
          :title="s__('ThreatMonitoring|Web Application Firewall')"
          :subtitle="s__('ThreatMonitoring|Requests')"
          :anomalous-title="s__('ThreatMonitoring|Anomalous Requests')"
          :nominal-title="s__('ThreatMonitoring|Total Requests')"
          :y-legend="s__('ThreatMonitoring|Requests')"
          :chart-empty-state-title="s__('ThreatMonitoring|Application firewall not detected')"
          :chart-empty-state-text="$options.wafChartEmptyStateDescription"
          :chart-empty-state-svg-path="wafNoDataSvgPath"
          :documentation-path="documentationPath"
          documentation-anchor="web-application-firewall"
        />

        <hr />

        <threat-monitoring-section
          ref="networkPolicySection"
          store-namespace="threatMonitoringNetworkPolicy"
          :title="s__('ThreatMonitoring|Container Network Policy')"
          :subtitle="s__('ThreatMonitoring|Packet Activity')"
          :anomalous-title="s__('ThreatMonitoring|Dropped Packets')"
          :nominal-title="s__('ThreatMonitoring|Total Packets')"
          :y-legend="s__('ThreatMonitoring|Operations Per Second')"
          :chart-empty-state-title="s__('ThreatMonitoring|Container NetworkPolicies not detected')"
          :chart-empty-state-text="$options.networkPolicyChartEmptyStateDescription"
          :chart-empty-state-svg-path="networkPolicyNoDataSvgPath"
          :documentation-path="documentationPath"
          documentation-anchor="container-network-policy"
        />
      </gl-tab>
    </gl-tabs>
  </section>
</template>
