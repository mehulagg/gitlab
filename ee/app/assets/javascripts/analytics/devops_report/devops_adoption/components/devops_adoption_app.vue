<script>
import { GlAlert } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import dateformat from 'dateformat';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_ERROR_KEYS,
  MAX_REQUEST_COUNT,
  MAX_SEGMENTS,
  DATE_TIME_FORMAT,
  DEFAULT_POLLING_INTERVAL,
  DEVOPS_ADOPTION_GROUP_LEVEL_LABEL,
  DEVOPS_ADOPTION_TABLE_CONFIGURATION,
} from '../constants';
import bulkFindOrCreateDevopsAdoptionSegmentsMutation from '../graphql/mutations/bulk_find_or_create_devops_adoption_segments.mutation.graphql';
import devopsAdoptionSegmentsQuery from '../graphql/queries/devops_adoption_segments.query.graphql';
import getGroupsQuery from '../graphql/queries/get_groups.query.graphql';
import { addSegmentsToCache, deleteSegmentsFromCache } from '../utils/cache_updates';
import { shouldPollTableData } from '../utils/helpers';
import DevopsAdoptionSection from './devops_adoption_section.vue';
import DevopsAdoptionSegmentModal from './devops_adoption_segment_modal.vue';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    GlAlert,
    DevopsAdoptionSection,
    DevopsAdoptionSegmentModal,
  },
  inject: {
    isGroup: {
      default: false,
    },
    groupGid: {
      default: null,
    },
  },
  i18n: {
    groupLevelLabel: DEVOPS_ADOPTION_GROUP_LEVEL_LABEL,
    ...DEVOPS_ADOPTION_STRINGS.app,
  },
  maxSegments: MAX_SEGMENTS,
  devopsAdoptionTableConfiguration: DEVOPS_ADOPTION_TABLE_CONFIGURATION,
  data() {
    return {
      isLoadingGroups: false,
      isLoadingEnableGroup: false,
      requestCount: 0,
      openModal: false,
      errors: {
        [DEVOPS_ADOPTION_ERROR_KEYS.groups]: false,
        [DEVOPS_ADOPTION_ERROR_KEYS.segments]: false,
        [DEVOPS_ADOPTION_ERROR_KEYS.addSegment]: false,
      },
      groups: {
        nodes: [],
        pageInfo: null,
      },
      pollingTableData: null,
      segmentsQueryVariables: this.isGroup
        ? {
            parentNamespaceId: this.groupGid,
            directDescendantsOnly: false,
          }
        : {},
    };
  },
  apollo: {
    devopsAdoptionSegments: {
      query: devopsAdoptionSegmentsQuery,
      variables() {
        return this.segmentsQueryVariables;
      },
      result({ data }) {
        if (this.isGroup) {
          const groupEnabled = data.devopsAdoptionSegments.nodes.some(
            ({ namespace: { id } }) => id === this.groupGid,
          );

          if (!groupEnabled) {
            this.enableGroup();
          }
        }
      },
      error(error) {
        this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.segments, error);
      },
    },
  },
  computed: {
    hasGroupData() {
      return Boolean(this.groups?.nodes?.length);
    },
    hasSegmentsData() {
      return Boolean(this.devopsAdoptionSegments?.nodes?.length);
    },
    hasLoadingError() {
      return Object.values(this.errors).some((error) => error === true);
    },
    timestamp() {
      return dateformat(
        this.devopsAdoptionSegments?.nodes[0]?.latestSnapshot?.recordedAt,
        DATE_TIME_FORMAT,
      );
    },
    isLoading() {
      return (
        this.isLoadingGroups ||
        this.isLoadingEnableGroup ||
        this.$apollo.queries.devopsAdoptionSegments.loading
      );
    },
    segmentLimitReached() {
      return this.devopsAdoptionSegments?.nodes?.length > this.$options.maxSegments;
    },
    editGroupsButtonLabel() {
      return this.isGroup
        ? this.$options.i18n.groupLevelLabel
        : this.$options.i18n.tableHeader.button;
    },
    canRenderModal() {
      return this.hasGroupData && !this.isLoading;
    },
  },
  created() {
    this.fetchGroups();
  },
  beforeDestroy() {
    clearInterval(this.pollingTableData);
  },
  methods: {
    openAddRemoveModal() {
      this.$refs.addRemoveModal.openModal();
    },
    enableGroup() {
      this.isLoadingEnableGroup = true;

      this.$apollo
        .mutate({
          mutation: bulkFindOrCreateDevopsAdoptionSegmentsMutation,
          variables: {
            namespaceIds: [this.groupGid],
          },
          update: (store, { data }) => {
            const {
              bulkFindOrCreateDevopsAdoptionSegments: { segments, errors },
            } = data;

            if (errors.length) {
              this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.addSegment, errors);
            } else {
              this.addSegmentsToCache(segments);
            }
          },
        })
        .catch((error) => {
          this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.addSegment, error);
        })
        .finally(() => {
          this.isLoadingEnableGroup = false;
        });
    },
    pollTableData() {
      const shouldPoll = shouldPollTableData({
        segments: this.devopsAdoptionSegments.nodes,
        timestamp: this.devopsAdoptionSegments?.nodes[0]?.latestSnapshot?.recordedAt,
        openModal: this.openModal,
      });

      if (shouldPoll) {
        this.$apollo.queries.devopsAdoptionSegments.refetch();
      }
    },
    trackModalOpenState(state) {
      this.openModal = state;
    },
    startPollingTableData() {
      this.pollingTableData = setInterval(this.pollTableData, DEFAULT_POLLING_INTERVAL);
    },
    handleError(key, error) {
      this.errors[key] = true;
      Sentry.captureException(error);
    },
    fetchGroups(nextPage) {
      this.isLoadingGroups = true;
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
            this.isLoadingGroups = false;
            this.startPollingTableData();
          }
        })
        .catch((error) => this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.groups, error));
    },
    addSegmentsToCache(segments) {
      const { cache } = this.$apollo.getClient();

      addSegmentsToCache(cache, segments, this.segmentsQueryVariables);
    },
    deleteSegmentsFromCache(ids) {
      const { cache } = this.$apollo.getClient();

      deleteSegmentsFromCache(cache, ids, this.segmentsQueryVariables);
    },
  },
};
</script>
<template>
  <div v-if="hasLoadingError">
    <template v-for="(error, key) in errors">
      <gl-alert v-if="error" :key="key" variant="danger" :dismissible="false" class="gl-mt-3">
        {{ $options.i18n[key] }}
      </gl-alert>
    </template>
  </div>

  <div v-else>
    <devops-adoption-segment-modal
      v-if="canRenderModal"
      ref="addRemoveModal"
      :groups="groups.nodes"
      :enabled-groups="devopsAdoptionSegments.nodes"
      @segmentsAdded="addSegmentsToCache"
      @segmentsRemoved="deleteSegmentsFromCache"
      @trackModalOpenState="trackModalOpenState"
    />
    <devops-adoption-section
      :is-loading="isLoading"
      :has-segments-data="hasSegmentsData"
      :timestamp="timestamp"
      :has-group-data="hasGroupData"
      :segment-limit-reached="segmentLimitReached"
      :edit-groups-button-label="editGroupsButtonLabel"
      :cols="$options.devopsAdoptionTableConfiguration[0].cols"
      :segments="devopsAdoptionSegments"
      @segmentsRemoved="deleteSegmentsFromCache"
      @openAddRemoveModal="openAddRemoveModal"
    />
  </div>
</template>
