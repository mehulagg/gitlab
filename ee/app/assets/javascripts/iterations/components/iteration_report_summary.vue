<script>
import IterationReportSummaryOpen from './iteration_report_summary_open.vue';
import IterationReportSummaryClosed from './iteration_report_summary_closed.vue';
import { iterationStates, Namespace } from '../constants';
import { FEATURE_FLAG_SCOPE } from '../../../../../../app/assets/javascripts/feature_flags/constants';

export default {
  components: {
    IterationReportSummaryOpen,
    IterationReportSummaryClosed,
  },
  props: {
    fullPath: {
      type: String,
      required: false,
      default: '',
    },
    namespaceType: {
      type: String,
      required: false,
      default: Namespace.Group,
      validator: value => Object.values(Namespace).includes(value),
    },
    iterationId: {
      type: String,
      required: true,
    },
    iterationState: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      issues: {},
    };
  },
  computed: {
    closed() {
      return this.iterationState === iterationStates.closed;
    },
  },
};
</script>

<template>
  <iteration-report-summary-closed v-if="closed" :iteration-id="iterationId" />
  <iteration-report-summary-open
    v-else
    :full-path="fullPath"
    :iteration-id="iterationId"
    :namespace-type="namespaceType"
  />
</template>
