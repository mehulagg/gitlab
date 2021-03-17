<script>
import { REPORT_TYPES } from './types/constants';
import List from './types/list.vue';
import Url from './types/url.vue';

export default {
  REPORT_TYPES,
  components: {
    List,
    Url,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
    nestingLevel: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  computed: {
    isSupportedReportType() {
      return this.$options.REPORT_TYPES.includes(this.item.type);
    },
  },
};
</script>
<template>
  <div v-if="isSupportedReportType">
    <component :is="item.type" v-bind="item" :nesting-level="nestingLevel" />
  </div>
</template>
