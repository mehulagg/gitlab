<script>
import PipelineStatus from './pipeline_status.vue';
import ValidationSegment from './validation_segment.vue';

export default {
  pipelineStatusClasses:
    'gl-p-5 gl-bg-gray-10 gl-border-solid gl-border-t-1 gl-border-l-1 gl-border-r-1 gl-border-b-0 gl-border-gray-100 gl-rounded-top-base',
  validationSegmentClasses:
    'gl-p-5 gl-bg-gray-10 gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-bottom-base',
  components: {
    PipelineStatus,
    ValidationSegment,
  },
  props: {
    ciConfigData: {
      type: Object,
      required: true,
    },
    isCiConfigDataLoading: {
      type: Boolean,
      required: true,
    },
  },
};
</script>
<template>
  <div class="gl-mb-5">
    <pipeline-status
      :class="$options.pipelineStatusClasses"
    />
    <validation-segment
      :class="$options.validationSegmentClasses"
      :loading="isCiConfigDataLoading"
      :ci-config="ciConfigData"
    />
  </div>
</template>
