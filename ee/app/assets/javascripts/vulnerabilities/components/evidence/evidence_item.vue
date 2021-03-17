<script>
import Url from './types/url.vue';

export default {
  name: 'EvidenceItem',
  maxNestingLevel: 3,
  components: {
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
      default: 1,
    },
  },
  computed: {
    nextNestingLevel() {
      return this.nestingLevel + 1;
    },
    supportedTypes() {
      return Object.keys(this.$options.components).map((x) => x.toLowerCase());
    },
    isSupportedType() {
      return this.isListItem || this.supportedTypes.includes(this.item.type);
    },
    isListItem() {
      return this.item.type === 'list';
    },
    maxNestingLevelReached() {
      return this.nestingLevel >= this.$options.maxNestingLevel;
    },
  },
};
</script>
<template>
  <div v-if="isSupportedType">
    <component :is="item.type" v-bind="item" v-if="!isListItem" />
    <template v-else-if="!maxNestingLevelReached">
      <evidence-item
        v-for="listItem in item.items"
        :key="listItem.key"
        :item="listItem"
        :nesting-level="nextNestingLevel"
      />
    </template>
  </div>
</template>
