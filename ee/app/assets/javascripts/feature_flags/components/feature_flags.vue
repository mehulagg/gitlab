<script>
import { createNamespacedHelpers } from 'vuex';
import { isEmpty } from 'lodash';
import { GlButton, GlModalDirective, GlTabs } from '@gitlab/ui';
import { FEATURE_FLAG_SCOPE, USER_LIST_SCOPE } from '../constants';
import Tab from './tab.vue';
import FeatureFlagsTable from './feature_flags_table.vue';
import UserListsTable from './user_lists_table.vue';
import store from '../store';
import { s__ } from '~/locale';
import TablePagination from '~/vue_shared/components/pagination/table_pagination.vue';
import {
  getParameterByName,
  historyPushState,
  buildUrlWithCurrentLocation,
} from '~/lib/utils/common_utils';

import ConfigureFeatureFlagsModal from './configure_feature_flags_modal.vue';

const { mapState, mapActions } = createNamespacedHelpers('index');

const scopes = {
  [FEATURE_FLAG_SCOPE]: FEATURE_FLAG_SCOPE,
  [USER_LIST_SCOPE]: USER_LIST_SCOPE,
};

export default {
  store,
  components: {
    FeatureFlagsTable,
    UserListsTable,
    TablePagination,
    GlButton,
    GlTabs,
    Tab,
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
    projectId: {
      type: String,
      required: true,
    },
    csrfToken: {
      type: String,
      required: true,
    },
    featureFlagsClientLibrariesHelpPagePath: {
      type: String,
      required: true,
    },
    featureFlagsClientExampleHelpPagePath: {
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
    newUserListPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    const scope = getParameterByName('scope') || this.$options.scopes.featureFlags;
    return {
      scope,
      page: getParameterByName('page') || '1',
      isUserListAlertDismissed: false,
      selectedTab: Object.values(scopes).indexOf(scope),
    };
  },
  scopes,
  computed: {
    ...mapState([
      FEATURE_FLAG_SCOPE,
      USER_LIST_SCOPE,
      'alerts',
      'count',
      'pageInfo',
      'isLoading',
      'hasError',
      'options',
      'instanceId',
      'isRotating',
      'hasRotateError',
    ]),
    topAreaBaseClasses() {
      return ['gl-display-flex', 'gl-flex-direction-column'];
    },
    canUserRotateToken() {
      return this.rotateInstanceIdPath !== '';
    },
    currentlyDisplayedData() {
      return this.dataForScope(this.scope);
    },
    shouldRenderPagination() {
      return (
        !this.isLoading &&
        !this.hasError &&
        this.currentlyDisplayedData.length > 0 &&
        this.pageInfo[this.scope].total > this.pageInfo[this.scope].perPage
      );
    },
    shouldShowEmptyState() {
      return !this.isLoading && !this.hasError && this.currentlyDisplayedData.length === 0;
    },
    shouldRenderErrorState() {
      return this.hasError && !this.isLoading;
    },
    hasNewPath() {
      return !isEmpty(this.newFeatureFlagPath);
    },
    emptyStateTitle() {
      return s__('FeatureFlags|Get started with feature flags');
    },
  },
  created() {
    this.setFeatureFlagsEndpoint(this.endpoint);
    this.setFeatureFlagsOptions({ scope: this.scope, page: this.page });
    this.setProjectId(this.projectId);
    this.fetchFeatureFlags();
    this.fetchUserLists();
    this.setInstanceId(this.unleashApiInstanceId);
    this.setInstanceIdEndpoint(this.rotateInstanceIdPath);
  },
  methods: {
    ...mapActions([
      'setFeatureFlagsEndpoint',
      'setFeatureFlagsOptions',
      'fetchFeatureFlags',
      'fetchUserLists',
      'setInstanceIdEndpoint',
      'setInstanceId',
      'setProjectId',
      'rotateInstanceId',
      'toggleFeatureFlag',
      'deleteUserList',
      'clearAlert',
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
      if (this.scope === this.$options.scopes.featureFlags) {
        this.fetchFeatureFlags();
      } else {
        this.fetchUserLists();
      }
    },
    shouldRenderTable(scope) {
      return (
        !this.isLoading &&
        this.dataForScope(scope).length > 0 &&
        !this.hasError &&
        this.scope === scope
      );
    },
    dataForScope(scope) {
      return this[scope];
    },
  },
};
</script>
<template>
  <div>
    <configure-feature-flags-modal
      v-if="canUserConfigure"
      :help-client-libraries-path="featureFlagsClientLibrariesHelpPagePath"
      :help-client-example-path="featureFlagsClientExampleHelpPagePath"
      :api-url="unleashApiUrl"
      :instance-id="instanceId"
      :is-rotating="isRotating"
      :has-rotate-error="hasRotateError"
      :can-user-rotate-token="canUserRotateToken"
      modal-id="configure-feature-flags"
      @token="rotateInstanceId()"
    />
    <div :class="topAreaBaseClasses">
      <div class="gl-display-flex gl-flex-direction-column gl-display-md-none!">
        <gl-button
          v-if="canUserConfigure"
          v-gl-modal="'configure-feature-flags'"
          variant="info"
          category="secondary"
          data-qa-selector="configure_feature_flags_button"
          data-testid="ff-configure-button"
          class="gl-mb-3"
        >
          {{ s__('FeatureFlags|Configure') }}
        </gl-button>

        <gl-button
          v-if="newUserListPath"
          :href="newUserListPath"
          variant="success"
          category="secondary"
          class="gl-mb-3"
          data-testid="ff-new-list-button"
        >
          {{ s__('FeatureFlags|New list') }}
        </gl-button>

        <gl-button
          v-if="hasNewPath"
          :href="newFeatureFlagPath"
          variant="success"
          data-testid="ff-new-button"
        >
          {{ s__('FeatureFlags|New feature flag') }}
        </gl-button>
      </div>
      <gl-tabs v-model="selectedTab" class="gl-align-items-center gl-w-full">
        <tab
          :title="s__('FeatureFlags|Feature Flags')"
          :count="count.featureFlags"
          :alerts="alerts"
          :is-loading="isLoading"
          :loading-label="s__('FeatureFlags|Loading feature flags')"
          :error-state="shouldRenderErrorState"
          :error-title="s__(`FeatureFlags|There was an error fetching the feature flags.`)"
          :empty-state="shouldShowEmptyState"
          :empty-title="emptyStateTitle"
          data-testid="feature-flags-tab"
          @dismissAlert="clearAlert"
          @changeTab="onChangeTab($options.scopes.featureFlags)"
        >
          <feature-flags-table
            v-if="shouldRenderTable($options.scopes.featureFlags)"
            :csrf-token="csrfToken"
            :feature-flags="featureFlags"
            @toggle-flag="toggleFeatureFlag"
          />
        </tab>
        <tab
          :title="s__('FeatureFlags|User Lists')"
          :count="count.userLists"
          :alerts="alerts"
          :is-loading="isLoading"
          :loading-label="s__('FeatureFlags|Loading user lists')"
          :error-state="shouldRenderErrorState"
          :error-title="s__(`FeatureFlags|There was an error fetching the user lists.`)"
          :empty-state="shouldShowEmptyState"
          :empty-title="emptyStateTitle"
          data-testid="user-lists-tab"
          @dismissAlert="clearAlert"
          @changeTab="onChangeTab($options.scopes.userLists)"
        >
          <user-lists-table
            v-if="shouldRenderTable($options.scopes.userLists)"
            :user-lists="userLists"
            @delete="deleteUserList"
          />
        </tab>
        <template #tabs-end>
          <div
            class="gl-display-none gl-display-md-flex gl-align-items-center gl-flex-fill-1 gl-justify-content-end"
          >
            <gl-button
              v-if="canUserConfigure"
              v-gl-modal="'configure-feature-flags'"
              variant="info"
              category="secondary"
              data-qa-selector="configure_feature_flags_button"
              data-testid="ff-configure-button"
              class="mb-0 mr-3"
            >
              {{ s__('FeatureFlags|Configure') }}
            </gl-button>

            <gl-button
              v-if="newUserListPath"
              :href="newUserListPath"
              variant="success"
              category="secondary"
              class="mb-0 mr-3"
              data-testid="ff-new-list-button"
            >
              {{ s__('FeatureFlags|New list') }}
            </gl-button>

            <gl-button
              v-if="hasNewPath"
              :href="newFeatureFlagPath"
              variant="success"
              data-testid="ff-new-button"
            >
              {{ s__('FeatureFlags|New feature flag') }}
            </gl-button>
          </div>
        </template>
      </gl-tabs>
    </div>
    <table-pagination
      v-if="shouldRenderPagination"
      :change="onChangePage"
      :page-info="pageInfo[scope]"
    />
  </div>
</template>
