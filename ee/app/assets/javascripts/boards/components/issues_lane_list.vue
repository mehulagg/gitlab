<script>
import { mapState, mapActions } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import BoardCardLayout from '~/boards/components/board_card_layout.vue';
import eventHub from '~/boards/eventhub';
import BoardNewIssue from '~/boards/components/board_new_issue.vue';
import { ISSUABLE } from '~/boards/constants';

export default {
  components: {
    BoardCardLayout,
    BoardNewIssue,
    GlLoadingIcon,
  },
  props: {
    list: {
      type: Object,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
    issues: {
      type: Array,
      required: true,
      default: () => [],
    },
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
    isUnassignedIssuesLane: {
      type: Boolean,
      required: false,
      default: false,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    rootPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showIssueForm: false,
    };
  },
  computed: {
    ...mapState(['activeId']),
  },
  created() {
    eventHub.$on(`toggle-issue-form-${this.list.id}`, this.toggleForm);
  },
  beforeDestroy() {
    eventHub.$off(`toggle-issue-form-${this.list.id}`, this.toggleForm);
  },
  methods: {
    ...mapActions(['setActiveId']),
    toggleForm() {
      this.showIssueForm = !this.showIssueForm;
      if (this.showIssueForm && this.isUnassignedIssuesLane) {
        this.$el.scrollIntoView(false);
      }
    },
    isActiveIssue(issue) {
      return this.activeId === issue.id;
    },
    showIssue(issue) {
      this.setActiveId({ id: issue.id, sidebarType: ISSUABLE });
    },
  },

  emits: [],
};
</script>

<template>
  <div
    class="board gl-px-3 gl-vertical-align-top gl-white-space-normal gl-display-flex gl-flex-shrink-0"
    :class="{ 'is-collapsed': !list.isExpanded }"
  >
    <div class="board-inner gl-rounded-base gl-relative gl-w-full">
      <gl-loading-icon v-if="isLoading" class="gl-p-2" />
      <board-new-issue
        v-if="list.type !== 'closed' && showIssueForm && isUnassignedIssuesLane"
        :group-id="groupId"
        :list="list"
      />
      <ul v-if="list.isExpanded" class="gl-p-2 gl-m-0">
        <board-card-layout
          v-for="(issue, index) in issues"
          ref="issue"
          :key="issue.id"
          :index="index"
          :list="list"
          :issue="issue"
          :root-path="rootPath"
          :is-active="isActiveIssue(issue)"
          @show="showIssue(issue)"
        />
      </ul>
    </div>
  </div>
</template>
