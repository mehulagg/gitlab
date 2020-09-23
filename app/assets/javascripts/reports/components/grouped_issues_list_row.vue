<script>
import ReportItem from '~/reports/components/report_item.vue';

export default {
  name: 'GroupedIssuesListRow',
  components: {
    ReportItem,
  },
  props: {
    index: {
      type: Number,
      required: true,
    },
    source: {
      type: Object,
      required: true,
    },
    extraProps: {
      type: Object,
      required: true,
    }
  }
};
</script>
<template>
  <div>
    <h2
      :key="source.name"
      :data-testid="`${source.name}Heading`"
      :class="[index > 0 ? 'mt-2' : 'mt-0']"
      class="h5 mb-1"
    >
      {{ source.heading }}
    </h2>
    <report-item
      v-for="(issue, issueIndex) in source.issues"
      :key="`${source.name}-${issue.name}-${source.name}-${issueIndex}`"
      :issue="issue"
      :show-report-section-status-icon="false"
      :component="extraProps.component"
      status="none"
    />
  </div>
</template>