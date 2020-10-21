<script>
import { mapGetters } from 'vuex';
import IssuableTimeTracker from '~/sidebar/components/time_tracking/time_tracker.vue';

export default {
  inject: ['timeTrackingLimitToHours'],
  components: {
    IssuableTimeTracker,
  },
  computed: {
    ...mapGetters({ issue: 'getActiveIssue' }),
  },
};
</script>

<template>
  <div class="block">
    <issuable-time-tracker
      :time-estimate="this.issue.timeEstimate"
      :time-spent="this.issue.totalTimeSpent"
      :human-time-estimate="this.issue.humanTimeEstimate"
      :human-time-spent="this.issue.humanTotalTimeSpent"
      :limit-to-hours="timeTrackingLimitToHours"
      :collapsible="false"
    />
  </div>
</template>
