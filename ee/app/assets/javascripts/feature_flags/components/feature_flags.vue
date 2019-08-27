<script>
import { createNamespacedHelpers } from 'vuex';
import _ from 'lodash-es';
import { GlEmptyState, GlLoadingIcon, GlButton, GlModalDirective, GlLink } from '@gitlab/ui';
import FeatureFlagsTable from './feature_flags_table.vue';
import store from '../store';
import { __, s__ } from '~/locale';
import NavigationTabs from '~/vue_shared/components/navigation_tabs.vue';
import TablePagination from '~/vue_shared/components/pagination/table_pagination.vue';
import {
  getParameterByName,
  historyPushState,
  buildUrlWithCurrentLocation,
} from '~/lib/utils/common_utils';

import ConfigureFeatureFlagsModal from './configure_feature_flags_modal.vue';

const { mapState, mapActions } = createNamespacedHelpers('index');

export default {
  store,
  components: {
    FeatureFlagsTable,
    NavigationTabs,
    TablePagination,
    GlEmptyState,
    GlLoadingIcon,
    GlButton,
    GlLink,
    ConfigureFeatureFlagsModal,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    csrfToken: {
      type: String,
      required: true,
    },
    errorStateSvgPath: {
      type: String,
      required: true,
    },
    featureFlagsHelpPagePath: {
      type: String,
      required: true,
    },
    featureFlagsAnchoredHelpPagePath: {
      type: String,
      required: true,
    },
    rotateInstanceIdPath: {
      type: String,
      required: false,
      default: '',
    },
    unleashApiUrl: {
      type: String,
      required: true,
    },
    unleashApiInstanceId: {
      type: String,
      required: true,
    },
    canUserConfigure: {
      type: Boolean,
      required: true,
    },
    newFeatureFlagPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      scope: getParameterByName('scope') || this.$options.scopes.all,
      page: getParameterByName('page') || '1',
    };
  },
  scopes: {
    all: 'all',
    enabled: 'enabled',
    disabled: 'disabled',
  },
  computed: {
    ...mapState([
      'featureFlags',
      'count',
      'pageInfo',
      'isLoading',
      'hasError',
      'options',
      'instanceId',
      'isRotating',
      'hasRotateError',
    ]),
    canUserRotateToken() {
      return this.rotateInstanceIdPath !== '';
    },
    shouldRenderTabs() {
      /* Do not show tabs until after the first request to get the count */
      return this.count.all !== undefined;
    },
    shouldRenderPagination() {
      return (
        !this.isLoading &&
        !this.hasError &&
        this.featureFlags.length &&
        this.pageInfo.total > this.pageInfo.perPage
      );
    },
    shouldShowEmptyState() {
      return !this.isLoading && !this.hasError && this.featureFlags.length === 0;
    },
    shouldRenderTable() {
      return !this.isLoading && this.featureFlags.length > 0 && !this.hasError;
    },
    shouldRenderErrorState() {
      return this.hasError && !this.isLoading;
    },
    tabs() {
      const { scopes } = this.$options;

      return [
        {
          name: __('All'),
          scope: scopes.all,
          count: this.count.all,
          isActive: this.scope === scopes.all,
        },
        {
          name: __('Enabled'),
          scope: scopes.enabled,
          count: this.count.enabled,
          isActive: this.scope === scopes.enabled,
        },
        {
          name: __('Disabled'),
          scope: scopes.disabled,
          count: this.count.disabled,
          isActive: this.scope === scopes.disabled,
        },
      ];
    },
    hasNewPath() {
      return !_.isEmpty(this.newFeatureFlagPath);
    },
    emptyStateTitle() {
      if (this.scope === this.$options.scopes.disabled) {
        return s__(`FeatureFlags|There are no inactive feature flags`);
      } else if (this.scope === this.$options.scopes.enabled) {
        return s__(`FeatureFlags|There are no active feature flags`);
      }
      return s__(`FeatureFlags|Get started with feature flags`);
    },
  },
  created() {
    this.setFeatureFlagsEndpoint(this.endpoint);
    this.setFeatureFlagsOptions({ scope: this.scope, page: this.page });
    this.fetchFeatureFlags();
    this.setInstanceId(this.unleashApiInstanceId);
    this.setInstanceIdEndpoint(this.rotateInstanceIdPath);
  },
  methods: {
    ...mapActions([
      'setFeatureFlagsEndpoint',
      'setFeatureFlagsOptions',
      'fetchFeatureFlags',
      'setInstanceIdEndpoint',
      'setInstanceId',
      'rotateInstanceId',
    ]),
    onChangeTab(scope) {
      this.scope = scope;
      this.updateFeatureFlagOptions({
        scope,
        page: '1',
      });
    },
    onChangePage(page) {
      this.updateFeatureFlagOptions({
        scope: this.scope,
        /* URLS parameters are strings, we need to parse to match types */
        page: Number(page).toString(),
      });
    },
    updateFeatureFlagOptions(parameters) {
      const queryString = Object.keys(parameters)
        .map(parameter => {
          const value = parameters[parameter];
          return `${parameter}=${encodeURIComponent(value)}`;
        })
        .join('&');

      historyPushState(buildUrlWithCurrentLocation(`?${queryString}`));
      this.setFeatureFlagsOptions(parameters);
      this.fetchFeatureFlags();
    },
  },
};
</script>
<template>
  <div>
    <configure-feature-flags-modal
      v-if="canUserConfigure"
      :help-path="featureFlagsHelpPagePath"
      :help-anchor="featureFlagsAnchoredHelpPagePath"
      :api-url="unleashApiUrl"
      :instance-id="instanceId"
      :is-rotating="isRotating"
      :has-rotate-error="hasRotateError"
      :can-user-rotate-token="canUserRotateToken"
      modal-id="configure-feature-flags"
      @token="rotateInstanceId()"
    />
    <h3 class="page-title with-button">
      {{ s__('FeatureFlags|Feature Flags') }}
      <div class="pull-right">
        <button
          v-if="canUserConfigure"
          v-gl-modal="'configure-feature-flags'"
          type="button"
          class="js-ff-configure append-right-8 btn-inverted btn btn-primary"
        >
          {{ s__('FeatureFlags|Configure') }}
        </button>

        <gl-button
          v-if="hasNewPath"
          :href="newFeatureFlagPath"
          variant="success"
          class="js-ff-new"
          >{{ s__('FeatureFlags|New feature flag') }}</gl-button
        >
      </div>
    </h3>

    <div v-if="shouldRenderTabs" class="top-area scrolling-tabs-container inner-page-scroll-tabs">
      <navigation-tabs :tabs="tabs" scope="featureflags" @onChangeTab="onChangeTab" />
    </div>

    <gl-loading-icon
      v-if="isLoading"
      :label="s__('FeatureFlags|Loading feature flags')"
      :size="3"
      class="js-loading-state prepend-top-20"
    />

    <gl-empty-state
      v-else-if="shouldRenderErrorState"
      :title="s__(`FeatureFlags|There was an error fetching the feature flags.`)"
      :description="s__(`FeatureFlags|Try again in a few moments or contact your support team.`)"
      :svg-path="errorStateSvgPath"
    />

    <gl-empty-state
      v-else-if="shouldShowEmptyState"
      class="js-feature-flags-empty-state"
      :title="emptyStateTitle"
      :svg-path="errorStateSvgPath"
    >
      <template v-slot:description>
        {{
          s__(
            'FeatureFlags|Feature flags allow you to configure your code into different flavors by dynamically toggling certain functionality.',
          )
        }}
        <gl-link :href="featureFlagsHelpPagePath" target="_blank" rel="noopener noreferrer">
          {{ s__('FeatureFlags|More information') }}
        </gl-link>
      </template>
    </gl-empty-state>

    <feature-flags-table
      v-else-if="shouldRenderTable"
      :csrf-token="csrfToken"
      :feature-flags="featureFlags"
    />

    <table-pagination v-if="shouldRenderPagination" :change="onChangePage" :page-info="pageInfo" />
  </div>
</template>
