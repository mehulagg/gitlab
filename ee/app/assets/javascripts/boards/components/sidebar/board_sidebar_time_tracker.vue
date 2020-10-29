<script>
import { mapGetters } from 'vuex';
import IssuableTimeTracker from '~/sidebar/components/time_tracking/time_tracker.vue';

export default {
  inject: ['timeTrackingLimitToHours'],
  components: {
    IssuableTimeTracker,
  },
  computed: {
    ...mapGetters(['getActiveIssue']),
  },
};
</script>

<template>
  <issuable-time-tracker
    :time-estimate="getActiveIssue.timeEstimate"
    :time-spent="getActiveIssue.totalTimeSpent"
    :human-time-estimate="getActiveIssue.humanTimeEstimate"
    :human-time-spent="getActiveIssue.humanTotalTimeSpent"
    :limit-to-hours="timeTrackingLimitToHours"
    :show-collapsed="false"
  />
</template>
