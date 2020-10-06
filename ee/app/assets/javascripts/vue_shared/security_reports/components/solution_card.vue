<script>
import { GlIcon } from '@gitlab/ui';

export default {
  components: { GlIcon },
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
      return (this.remediation && this.remediation.summary) || this.solution;
    },
    showCreateMergeRequestMsg() {
      return !this.hasMr && Boolean(this.remediation) && this.hasDownload;
    },
  },
};
</script>
<template>
  <div v-if="solutionText" class="md my-4">
    <h3 class="gl-display-flex gl-align-items-center">
      <gl-icon name="bulb" class="gl-mr-3" />
      {{ s__('ciReport|Solution') }}
    </h3>
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
