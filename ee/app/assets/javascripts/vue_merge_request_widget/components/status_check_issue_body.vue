<script>
import SummaryRow from '~/reports/components/summary_row.vue';
import { ICON_SUCCESS, ICON_PENDING } from '~/reports/constants';
import { APPROVED } from '../../reports/status_checks_report/constants';

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
  },
  computed: {
    statusIcon() {
      if (this.issue.status === APPROVED) {
        return ICON_SUCCESS;
      }
      return ICON_PENDING;
    },
  },
};
</script>

<template>
  <div class="gl-w-full" :data-testid="`mr-status-check-issue-${issue.id}`">
    <summary-row :status-icon="statusIcon" nested-summary>
      <template #summary>
        <span>{{ issue.name }}, {{ issue.external_url }}</span>
      </template>
    </summary-row>
  </div>
</template>
