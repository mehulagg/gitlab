<script>
import { mapGetters } from 'vuex';
import ListLabel from '~/boards/models/label';
import { __ } from '~/locale';
import BoardLabelsSelect from '~/vue_shared/components/sidebar/labels_select/base.vue';
import AssigneeSelect from './assignee_select.vue';
import BoardScopeCurrentIteration from './board_scope_current_iteration.vue';
import BoardMilestoneSelect from './milestone_select.vue';
import BoardWeightSelect from './weight_select.vue';

export default {
  components: {
    AssigneeSelect,
    BoardLabelsSelect,
    BoardMilestoneSelect,
    BoardScopeCurrentIteration,
    BoardWeightSelect,
  },

  props: {
    collapseScope: {
      type: Boolean,
      required: true,
    },
    canAdminBoard: {
      type: Boolean,
      required: true,
    },
    board: {
      type: Object,
      required: true,
    },
    labelsPath: {
      type: String,
      required: true,
    },
    labelsWebUrl: {
      type: String,
      required: true,
    },
    enableScopedLabels: {
      type: Boolean,
      required: false,
      default: false,
    },
    projectId: {
      type: Number,
      required: false,
      default: 0,
    },
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
    weights: {
      type: Array,
      required: false,
      default: () => [],
    },
  },

  data() {
    return {
      expanded: false,
    };
  },

  computed: {
    ...mapGetters(['isIssueBoard']),
    expandButtonText() {
      return this.expanded ? __('Collapse') : __('Expand');
    },
  },

  methods: {
    handleLabelClick(label) {
      if (label.isAny) {
        // eslint-disable-next-line vue/no-mutating-props
        this.board.labels = [];
      } else if (!this.board.labels.find((l) => l.id === label.id)) {
        // eslint-disable-next-line vue/no-mutating-props
        this.board.labels.push(
          new ListLabel({
            id: label.id,
            title: label.title,
            color: label.color,
            textColor: label.text_color,
          }),
        );
      } else {
        let { labels } = this.board;
        labels = labels.filter((selected) => selected.id !== label.id);
        // eslint-disable-next-line vue/no-mutating-props
        this.board.labels = labels;
      }
    },
  },
};
</script>

<template>
  <div data-qa-selector="board_scope_modal">
    <div v-if="canAdminBoard" class="media">
      <label class="label-bold gl-font-lg media-body">{{ __('Scope') }}</label>
      <button v-if="collapseScope" type="button" class="btn" @click="expanded = !expanded">
        {{ expandButtonText }}
      </button>
    </div>
    <p class="text-secondary gl-mb-3">
      {{ __('Board scope affects which issues are displayed for anyone who visits this board') }}
    </p>
    <div v-if="!collapseScope || expanded">
      <board-milestone-select
        v-if="isIssueBoard"
        :board="board"
        :group-id="groupId"
        :project-id="projectId"
        :can-edit="canAdminBoard"
      />

      <board-scope-current-iteration
        v-if="isIssueBoard"
        :can-admin-board="canAdminBoard"
        :iteration-id="board.iteration_id"
        @set-iteration="$emit('set-iteration', $event)"
      />

      <board-labels-select
        :context="board"
        :labels-path="labelsPath"
        :labels-web-url="labelsWebUrl"
        :can-edit="canAdminBoard"
        :show-create="canAdminBoard"
        :enable-scoped-labels="enableScopedLabels"
        variant="standalone"
        ability-name="issue"
        @onLabelClick="handleLabelClick"
        >{{ __('Any label') }}</board-labels-select
      >

      <assignee-select
        v-if="isIssueBoard"
        :board="board"
        :selected="board.assignee"
        :can-edit="canAdminBoard"
        :project-id="projectId"
        :group-id="groupId"
        any-user-text="Any assignee"
        field-name="assignee_id"
        label="Assignee"
        placeholder-text="Select assignee"
        wrapper-class="assignee"
      />

      <!-- eslint-disable vue/no-mutating-props -->
      <board-weight-select
        v-if="isIssueBoard"
        v-model="board.weight"
        :board="board"
        :weights="weights"
        :can-edit="canAdminBoard"
      />
      <!-- eslint-enable vue/no-mutating-props -->
    </div>
  </div>
</template>
