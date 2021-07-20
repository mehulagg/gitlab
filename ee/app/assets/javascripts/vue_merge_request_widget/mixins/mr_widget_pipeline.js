export default {
  computed: {
    /* We typically set defaults ([]) in the store or prop declarations, but because triggered
     * and triggeredBy are appended to `pipeline`, we can't set defaults in the store, and we
     * need to check their length here to prevent initializing linked-pipeline-mini-lists
     * unneccessarily. */
    triggered() {
      return this.pipeline.triggered || [];
    },
    triggeredBy() {
      const response = this.pipeline.triggered_by;
      return response ? [response] : [];
    },
  },
};
