<script>
import {
  GlLoadingIcon,
  GlButton,
  GlSprintf,
  GlAlert,
  GlModalDirective,
  GlTooltipDirective,
} from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import dateformat from 'dateformat';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_ERROR_KEYS,
  MAX_REQUEST_COUNT,
  MAX_SEGMENTS,
  DATE_TIME_FORMAT,
  DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  DEFAULT_POLLING_INTERVAL,
  DEVOPS_ADOPTION_GROUP_LEVEL_LABEL,
} from '../constants';
import bulkFindOrCreateDevopsAdoptionSegmentsMutation from '../graphql/mutations/bulk_find_or_create_devops_adoption_segments.mutation.graphql';
import devopsAdoptionSegmentsQuery from '../graphql/queries/devops_adoption_segments.query.graphql';
import getGroupsQuery from '../graphql/queries/get_groups.query.graphql';
import { addSegmentsToCache, deleteSegmentsFromCache } from '../utils/cache_updates';
import { shouldPollTableData } from '../utils/helpers';
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import DevopsAdoptionSegmentModal from './devops_adoption_segment_modal.vue';
import DevopsAdoptionTable from './devops_adoption_table.vue';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    GlAlert,
    GlLoadingIcon,
    DevopsAdoptionEmptyState,
    DevopsAdoptionSegmentModal,
    DevopsAdoptionTable,
    GlButton,
    GlSprintf,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
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
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  data() {
    return {
      isLoadingGroups: false,
      isLoadingEnableGroup: false,
      requestCount: 0,
      selectedSegment: null,
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
    modalKey() {
      return this.selectedSegment?.id;
    },
    segmentLimitReached() {
      return this.devopsAdoptionSegments.nodes?.length > this.$options.maxSegments;
    },
    addSegmentButtonTooltipText() {
      return this.segmentLimitReached ? this.$options.i18n.tableHeader.buttonTooltip : false;
    },
    editGroupsButtonLabel() {
      return this.isGroup
        ? this.$options.i18n.groupLevelLabel
        : this.$options.i18n.tableHeader.button;
    },
  },
  created() {
    this.fetchGroups();
  },
  beforeDestroy() {
    clearInterval(this.pollingTableData);
  },
  methods: {
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
    setSelectedSegment(segment) {
      this.selectedSegment = segment;
    },
    clearSelectedSegment() {
      this.selectedSegment = null;
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
  <gl-loading-icon v-else-if="isLoading" size="md" class="gl-my-5" />
  <div v-else>
    <devops-adoption-segment-modal
      v-if="hasGroupData"
      :key="modalKey"
      :groups="groups.nodes"
      :enabled-groups="devopsAdoptionSegments.nodes"
      @segmentsAdded="addSegmentsToCache"
      @segmentsRemoved="deleteSegmentsFromCache"
      @trackModalOpenState="trackModalOpenState"
    />
    <div v-if="hasSegmentsData" class="gl-mt-3">
      <div
        class="gl-display-flex gl-justify-content-space-between gl-align-items-center gl-my-3"
        data-testid="tableHeader"
      >
        <span class="gl-text-gray-400">
          <gl-sprintf :message="$options.i18n.tableHeader.text">
            <template #timestamp>{{ timestamp }}</template>
          </gl-sprintf>
        </span>
        <span
          v-if="hasGroupData"
          v-gl-tooltip.hover="addSegmentButtonTooltipText"
          data-testid="segmentButtonWrapper"
        >
          <gl-button
            v-gl-modal="$options.devopsSegmentModalId"
            :disabled="segmentLimitReached"
            @click="clearSelectedSegment"
            >{{ editGroupsButtonLabel }}</gl-button
          ></span
        >
      </div>
      <devops-adoption-table
        :segments="devopsAdoptionSegments.nodes"
        :selected-segment="selectedSegment"
        @set-selected-segment="setSelectedSegment"
        @segmentsRemoved="deleteSegmentsFromCache"
        @trackModalOpenState="trackModalOpenState"
      />
    </div>
    <devops-adoption-empty-state
      v-else
      :has-groups-data="hasGroupData"
      @clear-selected-segment="clearSelectedSegment"
    />
  </div>
</template>
