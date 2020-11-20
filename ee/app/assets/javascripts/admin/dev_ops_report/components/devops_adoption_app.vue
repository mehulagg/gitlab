<script>
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import * as Sentry from '~/sentry/wrapper';
import getGroupsQuery from '../graphql/queries/get_groups.query.graphql';
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import { DEVOPS_ADOPTION_STRINGS, MAX_REQUEST_COUNT } from '../constants';
import DevopsAdoptionSegmentModal from './devops_adoption_segment_modal.vue';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    GlAlert,
    GlLoadingIcon,
    DevopsAdoptionEmptyState,
    DevopsAdoptionSegmentModal,
  },
  i18n: {
    ...DEVOPS_ADOPTION_STRINGS.app,
  },
  data() {
    return {
      requestCount: MAX_REQUEST_COUNT,
      loadingError: false,
      selectedSegmentId: null,
    };
  },
  apollo: {
    groups: {
      query: getGroupsQuery,
      loadingKey: 'loading',
      result() {
        this.requestCount -= 1;

        if (this.requestCount > 0 && this.groups?.pageInfo?.nextPage) {
          this.fetchNextPage();
        }
      },
      error(error) {
        this.handleError(error);
      },
    },
  },
  computed: {
    hasGroupData() {
      return Boolean(this.groups?.nodes?.length);
    },
    isLoading() {
      return this.$apollo.queries.groups.loading;
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
  <div v-else>
    <devops-adoption-empty-state :has-groups-data="hasGroupData" />
    <devops-adoption-segment-modal
      v-if="hasGroupData"
      :groups="groups.nodes"
      :segment-id="selectedSegmentId"
    />
  </div>
</template>
