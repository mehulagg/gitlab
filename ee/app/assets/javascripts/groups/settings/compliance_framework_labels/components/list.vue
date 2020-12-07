<script>
import { GlAlert, GlBadge, GlLoadingIcon, GlTab, GlTabs } from '@gitlab/ui';

import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __ } from '~/locale';
import * as Sentry from '~/sentry/wrapper';

import getComplianceFrameworkQuery from '../graphql/queries/get_compliance_framework.query.graphql';
import ListItem from './list_item.vue';
import EmptyState from './list_empty_state.vue';

export default {
  components: {
    EmptyState,
    GlAlert,
    GlBadge,
    GlLoadingIcon,
    ListItem,
    GlTab,
    GlTabs,
  },
  props: {
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    groupPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      complianceFrameworks: [],
      error: '',
    };
  },
  apollo: {
    complianceFrameworks: {
      query: getComplianceFrameworkQuery,
      variables() {
        return {
          fullPath: this.groupPath,
        };
      },
      update(data) {
        return (
          data.namespace?.complianceFrameworks?.nodes?.map(framework => ({
            ...framework,
            parsedId: getIdFromGraphQLId(framework.id),
          })) || []
        );
      },
      error(error) {
        this.error = this.$options.i18n.fetchError;
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.loading;
    },
    hasLoaded() {
      return !this.isLoading && !this.error;
    },
    frameworksCount() {
      return this.complianceFrameworks.length;
    },
    regulatedCount() {
      return 0;
    },
  },
  i18n: {
    fetchError: __('Error fetching compliance framework labels data'),
    allTab: __('All'),
    regulatedTab: __('Regulated'),
  },
};
</script>
<template>
  <div class="gl-border-t-1 gl-border-t-solid gl-border-t-gray-100">
    <gl-alert v-if="error" class="gl-mt-5" variant="danger" :dismissible="false">
      {{ error }}
    </gl-alert>
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-5" />
    <empty-state v-if="hasLoaded && frameworksCount === 0" :image-path="emptyStateSvgPath" />

    <gl-tabs v-if="hasLoaded && frameworksCount > 0">
      <gl-tab :title="$options.i18n.allTab" class="gl-mt-6">
        <list-item
          v-for="framework in complianceFrameworks"
          :key="framework.id"
          :framework="framework"
        />
      </gl-tab>
      <gl-tab disabled>
        <template slot="title">
          <span>{{ $options.i18n.regulatedTab }}</span>
          <gl-badge size="sm" class="gl-tab-counter-badge">{{ regulatedCount }}</gl-badge>
        </template>
      </gl-tab>
    </gl-tabs>
  </div>
</template>
