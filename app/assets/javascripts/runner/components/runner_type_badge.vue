<script>
import { GlBadge } from '@gitlab/ui';
import { INSTANCE_TYPE, GROUP_TYPE, PROJECT_TYPE } from '../constants';

export default {
  components: {
    GlBadge,
  },
  props: {
    type: {
      type: String,
      required: true,
    },
  },
  INSTANCE_TYPE,
  GROUP_TYPE,
  PROJECT_TYPE,
};
</script>
<template>
  <gl-badge v-if="$options.INSTANCE_TYPE === type" variant="success" v-bind="$attrs">
    {{ s__('Runners|shared') }}
  </gl-badge>
  <gl-badge v-else-if="$options.GROUP_TYPE === type" variant="success" v-bind="$attrs">
    {{ s__('Runners|group') }}
  </gl-badge>
  <gl-badge v-else-if="$options.PROJECT_TYPE === type" variant="info" v-bind="$attrs">
    {{ s__('Runners|specific') }}
  </gl-badge>
</template>
