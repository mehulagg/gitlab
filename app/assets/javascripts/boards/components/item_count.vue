<script>
export default {
  name: 'IssueCount',
  props: {
    maxIssueCount: {
      type: Number,
      required: false,
      default: 0,
    },
    itemsSize: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  computed: {
    isMaxLimitSet() {
      return this.maxIssueCount !== 0;
    },
    issuesExceedMax() {
      return this.isMaxLimitSet && this.itemsSize > this.maxIssueCount;
    },
  },
};
</script>

<template>
  <div class="item-count text-nowrap">
    <span class="js-item-size" :class="{ 'text-danger': issuesExceedMax }">
      {{ itemsSize }}
    </span>
    <span v-if="isMaxLimitSet" class="js-max-issue-size">
      {{ maxIssueCount }}
    </span>
  </div>
</template>
