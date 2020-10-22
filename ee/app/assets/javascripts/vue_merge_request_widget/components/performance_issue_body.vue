<script>
/**
 * Renders Perfomance issue body text
 *  [name] :[score] [symbol] [delta] in [link]
 */
import ReportLink from '~/reports/components/report_link.vue';

function formatScore(value) {
  if (Number(value) && !Number.isInteger(value)) {
    return (Math.floor(parseFloat(value) * 100) / 100).toFixed(2);
  }
  return value;
}

export default {
  name: 'PerformanceIssueBody',

  components: {
    ReportLink,
  },

  props: {
    issue: {
      type: Object,
      required: true,
    },
  },

  computed: {
    issueScore() {
      return this.issue.score ? formatScore(this.issue.score) : false;
    },
    issueDelta() {
      if (!this.issue.delta) {
        return false;
      }
      if (this.issue.delta >= 0) {
        return `+${formatScore(this.issue.delta)}`;
      }
      return formatScore(this.issue.delta);
    },
  },
};
</script>
<template>
  <div class="report-block-list-issue-description gl-mt-2 gl-mb-2">
    <div class="report-block-list-issue-description-text">
      <template v-if="issueScore">
        {{ issue.name }}: <strong>{{ issueScore }}</strong>
      </template>
      <template v-else>
        {{ issue.name }}
      </template>
      <template v-if="issueDelta">
        ({{ issueDelta }})
      </template>
    </div>

    <report-link v-if="issue.path" :issue="issue" />
  </div>
</template>
