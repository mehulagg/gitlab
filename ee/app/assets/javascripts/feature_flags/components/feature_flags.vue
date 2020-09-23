<script>
import { createNamespacedHelpers } from 'vuex';
import { isEmpty } from 'lodash';
import {
  GlAlert,
  GlButton,
  GlEmptyState,
  GlLoadingIcon,
  GlModalDirective,
  GlLink,
} from '@gitlab/ui';
import { FEATURE_FLAG_SCOPE, USER_LIST_SCOPE } from '../constants';
import FeatureFlagsTable from './feature_flags_table.vue';
import UserListsTable from './user_lists_table.vue';
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
    UserListsTable,
    NavigationTabs,
    TablePagination,
    GlAlert,
    GlButton,
    GlEmptyState,
    GlLoadingIcon,
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
    projectId: {
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
    return {
      scope: getParameterByName('scope') || this.$options.scopes.featureFlags,
      page: getParameterByName('page') || '1',
      isUserListAlertDismissed: false,
    };
  },
  scopes: {
    [FEATURE_FLAG_SCOPE]: FEATURE_FLAG_SCOPE,
    [USER_LIST_SCOPE]: USER_LIST_SCOPE,
  },
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
    secondaryButtonClasses() {
      return ['gl-mb-3', 'gl-lg-mr-3', 'gl-lg-mb-0'];
    },
    navigationControlsClasses() {
      return [
        'gl-display-flex',
        'gl-flex-direction-column',
        'gl-mt-3',
        'gl-lg-flex-direction-row',
        'gl-lg-flex-fill-1',
        'gl-lg-justify-content-end',
        'gl-lg-mt-0',
      ];
    },
    topAreaBaseClasses() {
      return [
        'gl-border-1',
        'gl-border-b-gray-100',
        'gl-border-b-solid',
        'gl-flex-wrap',
        'gl-display-flex',
        'gl-flex-direction-column-reverse',
        'gl-lg-align-items-center',
        'gl-lg-flex-direction-row',
      ];
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
    tabs() {
      const { scopes } = this.$options;

      return [
        {
          name: __('Feature Flags'),
          scope: scopes[FEATURE_FLAG_SCOPE],
          count: this.count[FEATURE_FLAG_SCOPE],
          isActive: this.scope === scopes[FEATURE_FLAG_SCOPE],
        },
        {
          name: __('Lists'),
          scope: scopes[USER_LIST_SCOPE],
          count: this.count[USER_LIST_SCOPE],
          isActive: this.scope === scopes[USER_LIST_SCOPE],
        },
      ];
    },
    hasNewPath() {
      return !isEmpty(this.newFeatureFlagPath);
    },
    emptyStateTitle() {
      return s__(`FeatureFlags|Get started with feature flags`);
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
      :help-path="featureFlagsHelpPagePath"
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
      <navigation-tabs
        :tabs="tabs"
        scope="featureflags"
        class="gl-border-none!"
        @onChangeTab="onChangeTab"
      />
      <div :class="navigationControlsClasses">
        <gl-button
          v-if="canUserConfigure"
          v-gl-modal="'configure-feature-flags'"
          variant="info"
          category="secondary"
          data-qa-selector="configure_feature_flags_button"
          data-testid="ff-configure-button"
          :class="secondaryButtonClasses"
        >
          {{ s__('FeatureFlags|Configure') }}
        </gl-button>

        <gl-button
          v-if="newUserListPath"
          :href="newUserListPath"
          variant="success"
          category="secondary"
          :class="secondaryButtonClasses"
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
    </div>
    <gl-alert
      v-for="(message, index) in alerts"
      :key="index"
      data-testid="serverErrors"
      variant="danger"
      @dismiss="clearAlert(index)"
    >
      {{ message }}
    </gl-alert>

    <gl-loading-icon
      v-if="isLoading"
      :label="s__('FeatureFlags|Loading feature flags')"
      size="md"
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
      <template #description>
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
      v-else-if="shouldRenderTable($options.scopes.featureFlags)"
      :csrf-token="csrfToken"
      :feature-flags="featureFlags"
      @toggle-flag="toggleFeatureFlag"
    />

    <user-lists-table
      v-else-if="shouldRenderTable($options.scopes.userLists)"
      :user-lists="userLists"
      @delete="deleteUserList"
    />

    <table-pagination
      v-if="shouldRenderPagination"
      :change="onChangePage"
      :page-info="pageInfo[scope]"
    />
  </div>
</template>
