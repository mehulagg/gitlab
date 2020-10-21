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
      :time-estimate="issue.timeEstimate"
      :time-spent="issue.totalTimeSpent"
      :human-time-estimate="issue.humanTimeEstimate"
      :human-time-spent="issue.humanTotalTimeSpent"
      :limit-to-hours="timeTrackingLimitToHours"
      :collapsible="false"
    />
  </div>
</template>
