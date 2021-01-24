<script>
import { mapGetters } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import IterationSelect from 'ee/sidebar/components/iteration_select.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import { __, s__ } from '~/locale';

export default {
  i18n: {
    iteration: s__('IssueBoards|Iteration'),
  },
  components: {
    BoardEditableItem,
    IterationSelect,
    GlLoadingIcon,
  },
  data() {
    return {
      currentIteration: undefined,
      loading: false,
      editing: false,
    };
  },
  computed: {
    ...mapGetters(['activeIssue', 'projectPathForActiveIssue', 'groupPathForActiveIssue']),
  },
  methods: {
    onIterationUpdate(currentIteration) {
      this.currentIteration = currentIteration;
    },
  },
};
</script>

<template>
  <board-editable-item
    :title="$options.i18n.iteration"
    :loading="loading"
    @open="editing = true"
    @close="editing = false"
  >
    <template v-if="currentIteration" #collapsed>
      <strong class="gl-text-gray-900">{{ currentIteration.title }}</strong>
    </template>
    <gl-loading-icon v-if="loading" class="gl-py-4" />
    <!-- TODO add loading event handler -->
    <iteration-select
      ref="iterationDropdown"
      :group-path="groupPathForActiveIssue"
      :project-path="projectPathForActiveIssue"
      :issue-iid="activeIssue.iid"
      :dropdown-open="editing"
      @dropdownClose="editing = false"
      @iterationUpdate="onIterationUpdate"
    />
  </board-editable-item>
</template>
