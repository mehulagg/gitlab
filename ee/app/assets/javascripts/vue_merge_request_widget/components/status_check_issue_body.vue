<script>
import SummaryRow from '~/reports/components/summary_row.vue';

export default {
  name: 'StatusCheckIssueBody',
  components: {
    SummaryRow,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    status: {
      type: String,
      required: true,
    },
  },
  computed: {
    statusIcon() {
      return this.status === 'neutral' ? 'pending' : this.status;
    },
  },
};
</script>

<template>
  <div class="gl-w-full">
    <summary-row :status-icon="statusIcon" nested-summary class="">
      <template #summary>
        <span>{{ issue.name }}, {{ issue.url }}</span>
      </template>
    </summary-row>
  </div>
</template>
