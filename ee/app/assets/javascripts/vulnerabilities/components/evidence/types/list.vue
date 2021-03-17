<script>
export default {
  maxNestingLevel: 2,
  components: {
    EvidenceItem: () => import('../evidence_item.vue'),
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
  },
};
</script>
<template>
  <ul>
    <template v-for="item in items">
      <li
        v-if="item.type !== 'list' || nextNestingLevel !== $options.maxNestingLevel"
        :key="item.key"
      >
        <evidence-item :item="item" :nesting-level="nextNestingLevel" />
      </li>
    </template>
  </ul>
</template>
