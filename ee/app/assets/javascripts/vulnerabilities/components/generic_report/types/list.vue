<script>
import { isSupportedReportType, isListType } from './utils';

export default {
  isSupportedReportType,
  isListType,
  maxNestingLevel: 3,
  components: {
    ReportItem: () => import('../report_item.vue'),
  },
  props: {
    items: {
      type: Array,
      required: true,
    },
    nestingLevel: {
      type: Number,
      required: false,
      default: 1,
    },
  },
  computed: {
    nextNestingLevel() {
      return this.nestingLevel + 1;
    },
    maxNestingLevelReached() {
      return this.nestingLevel >= this.$options.maxNestingLevel;
    },
    hasReachedMaximumNestingLevel() {
      return this.nextNestingLevel >= this.$options.maxNestingLevel;
    },
  },
  methods: {
    isListWithMaximumNestingLevel(type) {
      return this.$options.isListType(type) && this.hasReachedMaximumNestingLevel;
    },
    shouldRenderItem(item) {
      return (
        this.$options.isSupportedReportType(item.type) &&
        !this.isListWithMaximumNestingLevel(item.type)
      );
    },
  },
};
</script>
<template>
  <ul class="gl-list-style-none gl-m-0!">
    <template v-for="item in items">
      <li v-if="shouldRenderItem(item)" :key="item.name" class="gl-m-0!">
        <report-item :item="item" :nesting-level="nextNestingLevel" />
      </li>
    </template>
  </ul>
</template>
