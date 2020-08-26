<script>
import ApproversListEmpty from './approvers_list_empty.vue';
import ApproversListItem from './approvers_list_item.vue';

export default {
  components: {
    ApproversListEmpty,
    ApproversListItem,
  },
  props: {
    value: {
      type: Array,
      required: true,
    },
  },
  methods: {
    removeApprover(idx) {
      const newValue = [...this.value.slice(0, idx), ...this.value.slice(idx + 1)];
      this.$emit('input', newValue);
    },
  },

  emits: ['input'],
};
</script>

<template>
  <approvers-list-empty v-if="!value.length" />
  <ul v-else class="content-list">
    <approvers-list-item
      v-for="(approver, index) in value"
      :key="approver.type + approver.id"
      :approver="approver"
      @remove="removeApprover(index)"
    />
  </ul>
</template>
