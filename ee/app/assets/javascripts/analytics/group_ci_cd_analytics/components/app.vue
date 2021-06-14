<script>
import { GlTabs, GlTab } from '@gitlab/ui';
import DeploymentFrequencyCharts from 'ee/dora/components/deployment_frequency_charts.vue';
import LeadTimeCharts from 'ee/dora/components/lead_time_charts.vue';
import { mergeUrlParams, updateHistory, getParameterValues } from '~/lib/utils/url_utility';
import { TABS } from '../constants';
import ReleaseStatsCard from './release_stats_card.vue';

export default {
  name: 'CiCdAnalyticsApp',
  components: {
    ReleaseStatsCard,
    GlTabs,
    GlTab,
    DeploymentFrequencyCharts,
    LeadTimeCharts,
  },
  data() {
    return {
      selectedTabIndex: 0,
    };
  },
  created() {
    this.selectTab();
    window.addEventListener('popstate', this.selectTab);
  },
  methods: {
    selectTab() {
      const [tabQueryParam] = getParameterValues('tab');
      const tabIndex = TABS.indexOf(tabQueryParam);
      this.selectedTabIndex = tabIndex >= 0 ? tabIndex : 0;
    },
    onTabChange(newIndex) {
      if (newIndex !== this.selectedTabIndex) {
        this.selectedTabIndex = newIndex;
        const path = mergeUrlParams({ tab: TABS[newIndex] }, window.location.pathname);
        updateHistory({ url: path, title: window.title });
      }
    },
  },
};
</script>
<template>
  <div>
    <gl-tabs :value="selectedTabIndex" @input="onTabChange">
      <gl-tab :title="s__('CICDAnalytics|Release statistics')">
        <release-stats-card class="gl-mt-5" />
      </gl-tab>
      <gl-tab :title="s__('CICDAnalytics|Deployment frequency')">
        <deployment-frequency-charts />
      </gl-tab>
      <gl-tab :title="s__('CICDAnalytics|Lead time')">
        <lead-time-charts />
      </gl-tab>
    </gl-tabs>
  </div>
</template>
