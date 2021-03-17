<script>
import { typesComponents, supportedTypes } from './types';

export default {
  supportedTypes,
  components: {
    ...typesComponents,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
    nestingLevel: {
      type: Number,
      required: false,
      default: 1,
    },
  },
  computed: {
    isSupportedType() {
      return this.$options.supportedTypes.includes(this.item.type);
    },
  },
};
</script>
<template>
  <div v-if="isSupportedType">
    <component :is="item.type" v-bind="item" :nesting-level="nestingLevel" />
  </div>
</template>
