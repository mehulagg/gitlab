<script>
import { GlTabs, GlTab } from '@gitlab/ui';
import { mergeUrlParams, updateHistory, getParameterValues } from '~/lib/utils/url_utility';
import ReleaseStatsCard from './release_stats_card.vue';

const tabs = ['release-statistics', 'temp'];

export default {
  name: 'CiCdAnalyticsApp',
  components: {
    ReleaseStatsCard,
    GlTabs,
    GlTab,
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
      const tabIndex = tabs.indexOf(tabQueryParam);
      this.selectedTabIndex = tabIndex >= 0 ? tabIndex : 0;
    },
    onTabChange(newIndex) {
      if (newIndex !== this.selectedTabIndex) {
        this.selectedTabIndex = newIndex;
        const path = mergeUrlParams({ tab: tabs[newIndex] }, window.location.pathname);
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

      <gl-tab title="Temp tab">
        <p>Temporary!</p>
      </gl-tab>
    </gl-tabs>
  </div>
</template>
