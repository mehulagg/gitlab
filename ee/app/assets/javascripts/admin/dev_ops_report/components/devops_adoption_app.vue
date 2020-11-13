<script>
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import * as Sentry from '~/sentry/wrapper';
import getGroupsQuery from '../graphql/queries/get_groups.query.graphql';
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import { DEVOPS_ADOPTION_STRINGS } from '../constants';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    GlAlert,
    GlLoadingIcon,
    DevopsAdoptionEmptyState,
  },
  i18n: {
    ...DEVOPS_ADOPTION_STRINGS.app,
  },
  data() {
    return {
      loadingError: false,
    };
  },
  apollo: {
    groups: {
      query: getGroupsQuery,
      loadingKey: 'loading',
      result() {
        console.log('result:', this.groups);
        if (this.groups?.pageInfo?.nextPage) {
          this.fetchNextPage();
        }
      },
      error(error) {
        this.handleError(error);
      },
    },
  },
  computed: {
    isLoading() {
      console.log('loading:', this.$apollo.queries.groups.loading);
      return this.$apollo.queries.groups.loading;
    },
    isEmpty() {
      console.log('isEmpty:', this.groups?.nodes?.length === 0);
      return this.groups?.nodes?.length === 0;
    },
  },
  methods: {
    handleError(error) {
      this.loadingError = true;
      Sentry.captureException(error);
    },
    fetchNextPage() {
      this.$apollo.queries.groups
        .fetchMore({
          variables: {
            nextPage: this.groups.pageInfo.nextPage,
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const { nodes, ...rest } = fetchMoreResult.groups;
            const previousNodes = previousResult.groups.nodes;
            return { groups: { ...rest, nodes: [...previousNodes, ...nodes] } };
          },
        })
        .catch((error) =>{
          console.log('error:', error);
          this.handleError(error)
        });
    },
  },
};
</script>
<template>
  <gl-loading-icon v-if="isLoading" size="md" class="gl-my-5" />
  <gl-alert v-else-if="loadingError" variant="danger" :dismissible="false" class="gl-mt-3">
    {{ $options.i18n.groupsError }}
  </gl-alert>
  <devops-adoption-empty-state v-else-if="isEmpty" />
</template>
