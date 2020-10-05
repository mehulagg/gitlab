<script>
import { GlIntersperse } from '@gitlab/ui';

export default {
  name: 'DependencyPathViewer',
  components: {
    GlIntersperse,
  },
  props: {
    dependencies: {
      type: Array,
      required: true,
    },
  },
};
</script>

<template>
  <gl-intersperse separator=" / ">
    <span v-for="dependency in dependencies" :key="dependency.name">
      <span>{{ dependency.name }}</span
      ><span v-if="dependency.version" class="gl-font-sm"> {{ dependency.version }}</span>
    </span>
  </gl-intersperse>
</template>
