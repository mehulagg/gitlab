<script>
import { mapActions, mapState } from 'vuex';
import { GlAlert, GlDeprecatedDropdown, GlDeprecatedDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import InsightsPage from './insights_page.vue';
import InsightsConfigWarning from './insights_config_warning.vue';

export default {
  components: {
    GlAlert,
    GlLoadingIcon,
    InsightsPage,
    InsightsConfigWarning,
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    queryEndpoint: {
      type: String,
      required: true,
    },
    notice: {
      type: String,
      default: '',
      required: false,
    },
  },
  computed: {
    ...mapState('insights', [
      'configData',
      'configLoading',
      'activeTab',
      'activePage',
      'chartData',
    ]),
    pageLoading() {
      const requestedChartKeys = this.activePage?.charts?.map(chart => chart.title) || [];
      const storeChartKeys = Object.keys(this.chartData);
      const loadedCharts = storeChartKeys.filter(key => this.chartData[key].loaded);
      const chartsLoaded =
        Boolean(requestedChartKeys.length) &&
        requestedChartKeys.every(key => loadedCharts.includes(key));
      const chartsErrored = storeChartKeys.some(key => this.chartData[key].error);
      return !chartsLoaded && !chartsErrored;
    },
    pages() {
      const { configData, activeTab } = this;

      if (!configData) {
        return [];
      }

      if (!activeTab) {
        if (this.validSpecifiedTab()) {
          this.setActiveTab(this.specifiedTab);
        } else {
          const defaultTab = Object.keys(configData)[0];

          this.setActiveTab(defaultTab);
          this.$router.replace(defaultTab);
        }
      }

      return Object.keys(configData).map(key => ({
        name: configData[key].title,
        scope: key,
        isActive: this.activeTab === key,
      }));
    },
    allItemsAreFilteredOut() {
      return this.configPresent && Object.keys(this.configData).length === 0;
    },
    configPresent() {
      return !this.configLoading && this.configData != null;
    },
    specifiedTab() {
      return this.$route.params.tabId;
    },
  },
  mounted() {
    this.fetchConfigData(this.endpoint);
  },
  methods: {
    ...mapActions('insights', ['fetchConfigData', 'setActiveTab']),
    onChangePage(page) {
      if (this.validTab(page) && this.activeTab !== page) {
        this.$router.push(page);
      }
    },
    validSpecifiedTab() {
      return this.specifiedTab && this.validTab(this.specifiedTab);
    },
    validTab(tab) {
      return Object.prototype.hasOwnProperty.call(this.configData, tab);
    },
  },

  emits: [],
};
</script>
<template>
  <div class="insights-container gl-mt-3">
    <div class="mb-3">
      <h3>{{ __('Insights') }}</h3>
    </div>
    <div v-if="configLoading" class="insights-config-loading text-center">
      <gl-loading-icon :inline="true" size="lg" />
    </div>
    <div v-else-if="allItemsAreFilteredOut" class="insights-wrapper">
      <gl-alert>
        {{
          s__(
            'Insights|This project is filtered out in the insights.yml file (see the projects.only config for more information).',
          )
        }}
      </gl-alert>
    </div>
    <div v-else-if="configPresent" class="insights-wrapper">
      <gl-deprecated-dropdown
        class="js-insights-dropdown w-100"
        data-qa-selector="insights_dashboard_dropdown"
        menu-class="w-100 mw-100"
        toggle-class="dropdown-menu-toggle w-100 gl-field-error-outline"
        :text="__('Select Page')"
        :disabled="pageLoading"
      >
        <gl-deprecated-dropdown-item
          v-for="page in pages"
          :key="page.scope"
          class="w-100"
          @click="onChangePage(page.scope)"
          >{{ page.name }}</gl-deprecated-dropdown-item
        >
      </gl-deprecated-dropdown>
      <gl-alert v-if="notice != ''">
        {{ notice }}
      </gl-alert>
      <insights-page :query-endpoint="queryEndpoint" :page-config="activePage" />
    </div>
    <insights-config-warning
      v-else
      :title="__('Invalid Insights config file detected')"
      :summary="
        __(
          'Please check the configuration file to ensure that it is available and the YAML is valid',
        )
      "
      image="illustrations/monitoring/getting_started.svg"
    />
  </div>
</template>
