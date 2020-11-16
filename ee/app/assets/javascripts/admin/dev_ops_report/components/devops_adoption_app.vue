<script>
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import * as Sentry from '~/sentry/wrapper';
import getGroupsQuery from '../graphql/queries/get_groups.query.graphql';
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import { DEVOPS_ADOPTION_STRINGS, MAX_NO_REQEUSTS } from '../constants';

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
      maxFetches: MAX_NO_REQEUSTS,
      loadingError: false,
    };
  },
  apollo: {
    groups: {
      query: getGroupsQuery,
      loadingKey: 'loading',
      result() {
        this.maxFetches -= 1;

        if (this.maxFetches > 0 && this.groups?.pageInfo?.nextPage) {
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
      return this.$apollo.queries.groups.loading;
    },
    isEmpty() {
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
            const { nodes: previousNodes } = previousResult.groups;

            return { groups: { ...rest, nodes: [...previousNodes, ...nodes] } };
          },
        })
        .catch(this.handleError);
    },
  },
};
</script>
<template>
  <gl-alert v-if="loadingError" variant="danger" :dismissible="false" class="gl-mt-3">
    {{ $options.i18n.groupsError }}
  </gl-alert>
  <gl-loading-icon v-else-if="isLoading" size="md" class="gl-my-5" />
  <devops-adoption-empty-state v-else-if="isEmpty" />
</template>
