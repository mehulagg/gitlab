<script>
import { GlPath, GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { PATH_BACKGROUND_COLOR } from '../constants';

export default {
  name: 'PathNavigation',
  components: {
    GlPath,
    GlSkeletonLoading,
  },
  props: {
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    stages: {
      type: Array,
      required: true,
    },
    selectedStage: {
      type: Object,
      required: false,
      default: () => {},
    },
  },
  backgroundColor: PATH_BACKGROUND_COLOR,
};
</script>
<template>
  <gl-skeleton-loading v-if="loading" :lines="2" class="h-auto pt-2 pb-1" />
  <gl-path
    v-else
    :key="selectedStage.id"
    :items="stages"
    :background-color="$options.backgroundColor"
    @selected="$emit('selected', $event)"
  />
</template>
