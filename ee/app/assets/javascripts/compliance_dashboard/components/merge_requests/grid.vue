<script>
import { GlSprintf } from '@gitlab/ui';

import { __ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

import GridColumnHeading from '../shared/grid_column_heading.vue';
import Pagination from '../shared/pagination.vue';
import Approvers from './approvers.vue';
import BranchDetails from './branch_details.vue';
import MergeRequest from './merge_request.vue';
import Status from './status.vue';

export default {
  components: {
    Approvers,
    BranchDetails,
    GlSprintf,
    GridColumnHeading,
    MergeRequest,
    Pagination,
    Status,
    TimeAgoTooltip,
  },
  props: {
    mergeRequests: {
      type: Array,
      required: true,
    },
    isLastPage: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    key(id, value) {
      return `${id}-${value}`;
    },
    hasBranchDetails(mergeRequest) {
      return mergeRequest.target_branch && mergeRequest.source_branch;
    },
  },
  strings: {
    approvalStatusLabel: __('Approval Status'),
    mergedAtText: __('merged %{timeAgo}'),
    mergeRequestLabel: __('Merge Request'),
    pipelineStatusLabel: __('Pipeline'),
    updatesLabel: __('Updates'),
  },
  keyTypes: {
    mergeRequest: 'MR',
    approvalStatus: 'approvalStatus',
    pipeline: 'pipeline',
    updates: 'updates',
  },
};
</script>

<template>
  <div>
    <div class="dashboard-grid gl-display-grid gl-grid-tpl-rows-auto">
      <grid-column-heading :heading="$options.strings.mergeRequestLabel" />
      <grid-column-heading :heading="$options.strings.approvalStatusLabel" class="gl-text-center" />
      <grid-column-heading :heading="$options.strings.pipelineStatusLabel" class="gl-text-center" />
      <grid-column-heading :heading="$options.strings.updatesLabel" class="gl-text-right" />

      <template v-for="mergeRequest in mergeRequests">
        <merge-request
          :key="key(mergeRequest.id, $options.keyTypes.mergeRequest)"
          :merge-request="mergeRequest"
        />

        <status
          :key="key(mergeRequest.id, 'approval')"
          :status="{ type: 'approval', data: mergeRequest.approval_status }"
        />

        <status
          :key="key(mergeRequest.id, 'pipeline')"
          :status="{ type: 'pipeline', data: mergeRequest.pipeline_status }"
        />

        <div
          :key="key(mergeRequest.id, $options.keyTypes.updates)"
          class="gl-text-right gl-border-b-solid gl-border-b-1 gl-border-b-gray-100 gl-p-5 gl-relative"
        >
          <approvers :approvers="mergeRequest.approved_by_users" />
          <branch-details
            v-if="hasBranchDetails(mergeRequest)"
            :source-branch="{
              name: mergeRequest.source_branch,
              uri: mergeRequest.source_branch_uri,
            }"
            :target-branch="{
              name: mergeRequest.target_branch,
              uri: mergeRequest.target_branch_uri,
            }"
          />
          <time-ago-tooltip
            :time="mergeRequest.merged_at"
            tooltip-placement="bottom"
            class="gl-text-gray-500"
          >
            <template #default="{ timeAgo }">
              <gl-sprintf :message="$options.strings.mergedAtText">
                <template #timeAgo>{{ timeAgo }}</template>
              </gl-sprintf>
            </template>
          </time-ago-tooltip>
        </div>
      </template>
    </div>

    <pagination class="gl-mt-5" :is-last-page="isLastPage" />
  </div>
</template>
