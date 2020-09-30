<script>
import { mapState } from 'vuex';
import dateFormat from 'dateformat';
import {
  GlTable,
  GlLink,
  GlAvatarLink,
  GlAvatar,
  GlAvatarsInline,
  GlTooltipDirective,
  GlLoadingIcon,
  GlAlert,
  GlIcon,
} from '@gitlab/ui';
import { s__, n__ } from '~/locale';
import { approximateDuration, differenceInSeconds } from '~/lib/utils/datetime_utility';
import { filterToQueryObject } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import { dateFormats } from '../../shared/constants';
import throughputTableQuery from '../graphql/queries/throughput_table.query.graphql';
import {
  THROUGHPUT_TABLE_STRINGS,
  MERGE_REQUEST_ID_PREFIX,
  LINE_CHANGE_SYMBOLS,
  ASSIGNEES_VISIBLE,
  AVATAR_SIZE,
  MAX_RECORDS,
  THROUGHPUT_TABLE_TEST_IDS,
  PIPELINE_STATUS_ICON_CLASSES,
} from '../constants';

const TH_TEST_ID = { 'data-testid': THROUGHPUT_TABLE_TEST_IDS.TABLE_HEADERS };

export default {
  name: 'ThroughputTable',
  components: {
    GlTable,
    GlLink,
    GlAvatarLink,
    GlAvatar,
    GlAvatarsInline,
    GlLoadingIcon,
    GlAlert,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['fullPath'],
  tableHeaderFields: [
    {
      key: 'mr_details',
      label: s__('MergeRequestAnalytics|Merge Request'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'date_merged',
      label: s__('MergeRequestAnalytics|Date Merged'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'time_to_merge',
      label: s__('MergeRequestAnalytics|Time to merge'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'milestone',
      label: s__('MergeRequestAnalytics|Milestone'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'commits',
      label: s__('Commits'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'pipelines',
      label: s__('MergeRequestAnalytics|Pipelines'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'line_changes',
      label: s__('MergeRequestAnalytics|Line changes'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'assignees',
      label: s__('MergeRequestAnalytics|Assignees'),
      tdClass: 'merge-request-analytics-td',
      thAttr: TH_TEST_ID,
    },
  ],
  props: {
    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      type: Date,
      required: true,
    },
  },
  data() {
    return {
      throughputTableData: [],
      hasError: false,
    };
  },
  apollo: {
    throughputTableData: {
      query: throughputTableQuery,
      variables() {
        const options = filterToQueryObject({
          sourceBranches: this.selectedSourceBranch,
          targetBranches: this.selectedTargetBranch,
          milestoneTitle: this.selectedMilestone,
          authorUsername: this.selectedAuthor,
          assigneeUsername: this.selectedAssignee,
          labels: this.selectedLabelList,
        });

        return {
          fullPath: this.fullPath,
          limit: MAX_RECORDS,
          startDate: dateFormat(this.startDate, dateFormats.isoDate),
          endDate: dateFormat(this.endDate, dateFormats.isoDate),
          ...options,
        };
      },
      update: data => data.project.mergeRequests.nodes,
      error() {
        this.hasError = true;
      },
      context: {
        isSingleRequest: true,
      },
    },
  },
  computed: {
    ...mapState('filters', {
      selectedSourceBranch: state => state.branches.source.selected,
      selectedTargetBranch: state => state.branches.target.selected,
      selectedMilestone: state => state.milestones.selected,
      selectedAuthor: state => state.authors.selected,
      selectedAssignee: state => state.assignees.selected,
      selectedLabelList: state => state.labels.selectedList,
    }),
    tableDataAvailable() {
      return this.throughputTableData.length;
    },
    tableDataLoading() {
      return !this.hasError && this.$apollo.queries.throughputTableData.loading;
    },
    alertDetails() {
      return {
        class: this.hasError ? 'danger' : 'info',
        message: this.hasError
          ? THROUGHPUT_TABLE_STRINGS.ERROR_FETCHING_DATA
          : THROUGHPUT_TABLE_STRINGS.NO_DATA,
      };
    },
  },
  methods: {
    formatMergeRequestId(id) {
      return `${MERGE_REQUEST_ID_PREFIX}${id}`;
    },
    formatLineChangeAdditions(value) {
      return `${LINE_CHANGE_SYMBOLS.ADDITIONS}${value}`;
    },
    formatLineChangeDeletions(value) {
      return `${LINE_CHANGE_SYMBOLS.DELETITIONS}${value}`;
    },
    formatDateMerged(value) {
      return dateFormat(value, dateFormats.isoDate);
    },
    computeTimeToMerge(createdAt, mergedAt) {
      return approximateDuration(differenceInSeconds(new Date(createdAt), new Date(mergedAt)));
    },
    pipelineStatusClass(value) {
      return PIPELINE_STATUS_ICON_CLASSES[value] === undefined
        ? PIPELINE_STATUS_ICON_CLASSES.default
        : PIPELINE_STATUS_ICON_CLASSES[value];
    },
    formatApprovalText(approvals) {
      return n__('%d Approval', '%d Approvals', approvals);
    },
  },
  assigneesVisible: ASSIGNEES_VISIBLE,
  avatarSize: AVATAR_SIZE,
  testIds: THROUGHPUT_TABLE_TEST_IDS,
};
</script>
<template>
  <gl-loading-icon v-if="tableDataLoading" size="md" />
  <gl-table
    v-else-if="tableDataAvailable"
    :fields="$options.tableHeaderFields"
    :items="throughputTableData"
    stacked="sm"
    thead-class="thead-white gl-border-b-solid gl-border-b-1 gl-border-b-gray-100"
  >
    <template #cell(mr_details)="{ item }">
      <div
        class="gl-display-flex gl-flex-direction-column gl-flex-grow-1"
        :data-testid="$options.testIds.MERGE_REQUEST_DETAILS"
      >
        <div class="merge-request-title str-truncated">
          <gl-link
            :href="item.webUrl"
            target="_blank"
            class="gl-font-weight-bold gl-text-gray-900"
            >{{ item.title }}</gl-link
          >
          <ul class="horizontal-list gl-mb-0">
            <li class="gl-mr-3">{{ formatMergeRequestId(item.iid) }}</li>
            <li v-if="item.pipelines.nodes.length" class="gl-mr-3">
              <gl-icon
                :name="item.pipelines.nodes[0].detailedStatus.icon"
                :class="pipelineStatusClass(item.pipelines.nodes[0].detailedStatus.icon)"
              />
            </li>
            <li
              class="gl-mr-3 gl-display-flex gl-align-items-center"
              :class="{ 'gl-opacity-5': !item.labels.nodes.length }"
              :data-testid="$options.testIds.LABEL_DETAILS"
            >
              <gl-icon name="label" class="gl-mr-1" /><span>{{ item.labels.nodes.length }}</span>
            </li>
            <li
              class="gl-mr-3 gl-display-flex gl-align-items-center"
              :class="{ 'gl-opacity-5': !item.userNotesCount }"
              :data-testid="$options.testIds.COMMENT_COUNT"
            >
              <gl-icon name="comments" class="gl-mr-2" /><span>{{ item.userNotesCount }}</span>
            </li>
            <li
              v-if="item.approvedBy.nodes.length"
              class="gl-text-green-500"
              :data-testid="$options.testIds.APPROVED"
            >
              <gl-icon name="approval" class="gl-mr-2" /><span>{{
                formatApprovalText(item.approvedBy.nodes.length)
              }}</span>
            </li>
          </ul>
        </div>
      </div>
    </template>

    <template #cell(date_merged)="{ item }">
      <div :data-testid="$options.testIds.DATE_MERGED">{{ formatDateMerged(item.mergedAt) }}</div>
    </template>

    <template #cell(time_to_merge)="{ item }">
      <div :data-testid="$options.testIds.TIME_TO_MERGE">
        {{ computeTimeToMerge(item.createdAt, item.mergedAt) }}
      </div>
    </template>

    <template #cell(milestone)="{ item }">
      <div v-if="item.milestone" :data-testid="$options.testIds.MILESTONE">
        {{ item.milestone.title }}
      </div>
    </template>

    <template #cell(commits)="{ item }">
      <div :data-testid="$options.testIds.COMMITS">{{ item.commitCount }}</div>
    </template>

    <template #cell(pipelines)="{ item }">
      <div :data-testid="$options.testIds.PIPELINES">{{ item.pipelines.nodes.length }}</div>
    </template>

    <template #cell(line_changes)="{ item }">
      <div :data-testid="$options.testIds.LINE_CHANGES">
        <span class="gl-font-weight-bold gl-text-green-500">{{
          formatLineChangeAdditions(item.diffStatsSummary.additions)
        }}</span>
        <span class="gl-font-weight-bold gl-text-red-500">{{
          formatLineChangeDeletions(item.diffStatsSummary.deletions)
        }}</span>
      </div>
    </template>

    <template #cell(assignees)="{ item }">
      <div :data-testid="$options.testIds.ASSIGNEES">
        <gl-avatars-inline
          :avatars="item.assignees.nodes"
          :avatar-size="$options.avatarSize"
          :max-visible="$options.assigneesVisible"
          collapsed
        >
          <template #avatar="{ avatar }">
            <gl-avatar-link v-gl-tooltip target="_blank" :href="avatar.webUrl" :title="avatar.name">
              <gl-avatar :src="avatar.avatarUrl" :size="$options.avatarSize" />
            </gl-avatar-link>
          </template>
        </gl-avatars-inline>
      </div>
    </template>
  </gl-table>
  <gl-alert v-else :variant="alertDetails.class" :dismissible="false" class="gl-mt-4">{{
    alertDetails.message
  }}</gl-alert>
</template>
