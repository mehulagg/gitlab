<script>
import { GlAlert, GlLoadingIcon, GlTab, GlTabs } from '@gitlab/ui';

import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { s__ } from '~/locale';
import * as Sentry from '~/sentry/wrapper';

import getComplianceFrameworkQuery from '../graphql/queries/get_compliance_framework.query.graphql';
import ListItem from './list_item.vue';
import EmptyState from './list_empty_state.vue';

export default {
  components: {
    EmptyState,
    GlAlert,
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
        const nodes = data.namespace?.complianceFrameworks?.nodes;

        return (
          nodes?.map(framework => ({
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
    isEmpty() {
      return this.hasLoaded && this.frameworksCount === 0;
    },
    hasFrameworks() {
      return this.hasLoaded && this.frameworksCount > 0;
    },
    regulatedCount() {
      return 0;
    },
  },
  i18n: {
    fetchError: s__(
      'ComplianceFrameworks|Error fetching compliance frameworks data. Please refresh the page',
    ),
    allTab: s__('ComplianceFrameworks|All'),
    regulatedTab: s__('ComplianceFrameworks|Regulated'),
  },
};
</script>
<template>
  <div class="gl-border-t-1 gl-border-t-solid gl-border-t-gray-100">
    <gl-alert v-if="error" class="gl-mt-5" variant="danger" :dismissible="false">
      {{ error }}
    </gl-alert>
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-5" />
    <empty-state v-if="isEmpty" :image-path="emptyStateSvgPath" />

    <gl-tabs v-if="hasFrameworks">
      <gl-tab class="gl-mt-6" :title="$options.i18n.allTab">
        <list-item
          v-for="framework in complianceFrameworks"
          :key="framework.parsedId"
          :framework="framework"
        />
      </gl-tab>
      <gl-tab disabled :title="$options.i18n.regulatedTab" />
    </gl-tabs>
  </div>
</template>
