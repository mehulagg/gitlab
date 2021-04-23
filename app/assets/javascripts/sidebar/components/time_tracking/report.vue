<script>
import reportQuery from '../../queries/time_tracking_report.query.graphql';

export default {
  data() {
    return { report: [] };
  },
  inject: ["issuableGid"],
  apollo: {
    report: {
      query: reportQuery,
      variables() {
        return {
          id: this.issuableGid,
        };
      },
      update(data) {
        return data?.issue?.timelogs?.nodes ?? [];
      },
    },
  },
};
</script>

<template>
  <pre>
    {{ JSON.stringify(report, undefined, 2) }}
  </pre>
</template>