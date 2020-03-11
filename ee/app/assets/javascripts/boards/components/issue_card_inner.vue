<script>
import { isNumber } from 'lodash';
import IssueCardInner from '~/boards/components/issue_card_inner.vue';
import IssueCardWeight from 'ee/boards/components/issue_card_weight.vue';
import boardsStore from '~/boards/stores/boards_store';

export default {
  name: 'EEIssueCardInner',
  components: {
    IssueCardInner,
    IssueCardWeight,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    updateFilters: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    hasWeight() {
      return isNumber(this.issue.weight);
    },
  },
};
</script>

<template>
  <issue-card-inner
    :issue="issue"
    :update-filters="updateFilters"
    v-bind="$attrs"
    v-on="$listeners"
  >
    <template #info>
      <issue-card-weight v-if="hasWeight" :weight="issue.weight" />
    </template>
  </issue-card-inner>
</template>
