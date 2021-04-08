<script>
import { isListType } from './utils';

export default {
  isListType,
  components: {
    ReportItem: () => import('../report_item.vue'),
  },
  inheritAttrs: false,
  props: {
    items: {
      type: Array,
      required: true,
    },
  },
  computed: {
    hasNestedListItems() {
      return this.items.some(isListType);
    },
  },
};
</script>
<template>
  <ul class="generic-report-list" :class="{ 'generic-report-list-nested': hasNestedListItems }">
    <li
      v-for="item in items"
      :key="item.name"
      :class="{ 'gl-list-style-none!': $options.isListType(item) }"
    >
      <report-item :item="item" />
    </li>
  </ul>
</template>
