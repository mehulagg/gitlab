<script>
export default {
  props: {
    solution: {
      type: String,
      default: '',
      required: false,
    },
    remediation: {
      type: Object,
      default: null,
      required: false,
    },
    hasDownload: {
      type: Boolean,
      default: false,
      required: false,
    },
    hasMr: {
      type: Boolean,
      default: false,
      required: false,
    },
  },
  computed: {
    solutionText() {
      return this.solution || (this.remediation && this.remediation.summary);
    },
    showCreateMergeRequestMsg() {
      return !this.hasMr && Boolean(this.remediation) && this.hasDownload;
    },
  },
};
</script>
<template>
  <div v-if="solutionText" class="md my-4">
    <h3>{{ s__('ciReport|Solution') }}</h3>
    <div ref="solution-text">
      {{ solutionText }}
      <template v-if="showCreateMergeRequestMsg">
        {{
          s__(
            'ciReport|Create a merge request to implement this solution, or download and apply the patch manually.',
          )
        }}
      </template>
    </div>
  </div>
</template>
