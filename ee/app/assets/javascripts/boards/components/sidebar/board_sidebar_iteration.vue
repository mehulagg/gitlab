<script>
import { mapGetters } from 'vuex';
import IterationSelect from 'ee/sidebar/components/iteration_select.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import { s__ } from '~/locale';

export default {
  i18n: {
    iteration: s__('IssueBoards|Iteration'),
  },
  components: {
    BoardEditableItem,
    IterationSelect,
  },
  data() {
    return {
      currentIteration: null,
      editing: false,
    };
  },
  computed: {
    ...mapGetters(['activeIssue', 'projectPathForActiveIssue', 'groupPathForActiveIssue']),
    showCurrentIteration() {
      return this.currentIteration !== null;
    },
  },
  methods: {
    onOpen() {
      this.editing = true;
    },
    onClose() {
      this.editing = false;
      this.$refs.editableItem.collapse();
    },
    onIterationUpdate(currentIteration) {
      this.currentIteration = currentIteration;
    },
  },
};
</script>

<template>
  <board-editable-item
    ref="editableItem"
    :title="$options.i18n.iteration"
    @open="onOpen"
    @close="onClose"
  >
    <template #collapsed>
      <strong v-if="showCurrentIteration" class="gl-text-gray-900">{{
        currentIteration.title
      }}</strong>
    </template>
    <iteration-select
      ref="iterationDropdown"
      :group-path="groupPathForActiveIssue"
      :project-path="projectPathForActiveIssue"
      :issue-iid="activeIssue.iid"
      :dropdown-open="editing"
      @dropdownClose="onClose"
      @iterationUpdate="onIterationUpdate"
    />
  </board-editable-item>
</template>
