<script>
import Api from 'ee/api';
import MetricCard from '~/analytics/shared/components/metric_card.vue';
import createFlash from '~/flash';
import { __, s__ } from '~/locale';

export default {
  name: 'GroupActivityCard',
  components: {
    MetricCard,
  },
  inject: ['groupFullPath', 'groupName'],
  data() {
    return {
      isLoading: false,
      metrics: {
        mergeRequests: {
          value: null,
          label: s__('GroupActivityMetrics|Merge Requests opened'),
        },
        issues: { value: null, label: s__('GroupActivityMetrics|Issues opened') },
        newMembers: { value: null, label: s__('GroupActivityMetrics|Members added') },
      },
    };
  },
  computed: {
    metricsArray() {
      return Object.entries(this.metrics).map(([key, obj]) => {
        const { value, label } = obj;
        return {
          key,
          value,
          label,
        };
      });
    },
  },
  created() {
    this.fetchMetrics(this.groupFullPath);
  },
  methods: {
    fetchMetrics(groupPath) {
      this.isLoading = true;

      return Promise.all([
        Api.groupActivityMergeRequestsCount(groupPath),
        Api.groupActivityIssuesCount(groupPath),
        Api.groupActivityNewMembersCount(groupPath),
      ])
        .then(([mrResponse, issuesResponse, newMembersResponse]) => {
          this.metrics.mergeRequests.value = mrResponse.data.merge_requests_count;
          this.metrics.issues.value = issuesResponse.data.issues_count;
          this.metrics.newMembers.value = newMembersResponse.data.new_members_count;
          this.isLoading = false;
        })
        .catch(() => {
          createFlash({
            message: __('Failed to load group activity metrics. Please try again.'),
          });
          this.isLoading = false;
        });
    },
  },
};
</script>

<template>
  <metric-card
    :title="s__('GroupActivityMetrics|Recent activity (last 90 days)')"
    :metrics="metricsArray"
    :is-loading="isLoading"
  />
</template>
