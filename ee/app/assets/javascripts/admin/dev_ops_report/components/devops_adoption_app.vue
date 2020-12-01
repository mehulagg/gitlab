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
      requestCount: 0,
      loadingError: false,
      isLoading: false,
      selectedSegmentId: null,
      groups: {
        nodes: [],
        pageInfo: null,
      },
    };
  },
  computed: {
    hasGroupData() {
      return Boolean(this.groups?.nodes?.length);
    },
  },
  created() {
    this.fetchGroups();
  },
  methods: {
    handleError(error) {
      this.loadingError = true;
      Sentry.captureException(error);
    },
    fetchGroups(nextPage) {
      this.isLoading = true;
      this.$apollo
        .query({
          query: getGroupsQuery,
          variables: {
            nextPage,
          },
        })
        .then(({ data }) => {
          const { pageInfo, nodes } = data.groups;

          // Update data
          this.groups = {
            pageInfo,
            nodes: [...this.groups.nodes, ...nodes],
          };

          this.requestCount += 1;
          if (this.requestCount < MAX_REQUEST_COUNT && pageInfo?.nextPage) {
            this.fetchGroups(pageInfo.nextPage);
          } else {
            this.isLoading = false;
          }
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
