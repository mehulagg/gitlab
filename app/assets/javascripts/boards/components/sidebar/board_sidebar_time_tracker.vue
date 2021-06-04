<script>
import IssuableTimeTracker from '~/sidebar/components/time_tracking/time_tracker.vue';
import issueTimeTrackingQuery from '../../graphql/issue_time_tracking.query.graphql';
import { GlLoadingIcon } from '@gitlab/ui';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { __ } from '~/locale';

export default {
  i18n: {
    fetchError: __('Failed to fetch the time tracking data for the issue.'),
  },
  components: {
    GlLoadingIcon,
    IssuableTimeTracker,
  },
  inject: ['timeTrackingLimitToHours'],
  props: {
    id: {
      required: true,
      type: Number,
    },
  },
  apollo: {
    timeTracking: {
      query: issueTimeTrackingQuery,
      variables() {
        return {
          id: this.gid,
        };
      },
      update(data) {
        const trackingData = data?.issue;
        if (trackingData) {
          return trackingData;
        }

        this.$emit('fetch-error', { error, message: this.$options.i18n.fetchError });

        return {};
      },
      error(error) {
        this.$emit('fetch-error', { error, message: this.$options.i18n.fetchError });
      },
    },
  },
  computed: {
    gid() {
      return convertToGraphQLId('Issue', this.id);
    },
  },
};
</script>

<template>
  <div>
    <div v-if="$apollo.queries.timeTracking.loading" class="gl-display-flex gl-align-items-center">
      <span data-testid="title">{{ 'Time tracking' }}</span>
      <gl-loading-icon data-testid="loading-icon-dropdown" class="gl-ml-2" />
    </div>
    <issuable-time-tracker
      v-else
      :issuable-id="id.toString()"
      :time-estimate="timeTracking.timeEstimate"
      :time-spent="timeTracking.totalTimeSpent"
      :human-time-estimate="timeTracking.humanTimeEstimate"
      :human-time-spent="timeTracking.humanTotalTimeSpent"
      :limit-to-hours="timeTrackingLimitToHours"
      :show-collapsed="false"
    />
  </div>
</template>
