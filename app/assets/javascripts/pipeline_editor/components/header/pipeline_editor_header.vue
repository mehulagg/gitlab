<script>
import PipelineStatus from './pipeline_status.vue';
import ValidationSegment from './validation_segment.vue';

const baseClasses = ['gl-p-5', 'gl-bg-gray-10', 'gl-border-solid', 'gl-border-gray-100'];

const pipelineStatusClasses = [
  ...baseClasses,
  'gl-border-1',
  'gl-border-b-0!',
  'gl-rounded-top-base',
];

const validationSegmentClasses = [
  ...baseClasses,
  'gl-border-1',
  'gl-rounded-bottom-left-base',
  'gl-rounded-bottom-right-base',
];

export default {
  pipelineStatusClasses,
  validationSegmentClasses,
  components: {
    PipelineStatus,
    ValidationSegment,
  },
  props: {
    ciConfigData: {
      type: Object,
      required: true,
    },
    isNewCiConfigFile: {
      type: Boolean,
      required: true,
    },
  },
};
</script>
<template>
  <div class="gl-mb-5">
    <pipeline-status v-if="!isNewCiConfigFile" :class="$options.pipelineStatusClasses" />
    <validation-segment :class="$options.validationSegmentClasses" :ci-config="ciConfigData" />
  </div>
</template>
