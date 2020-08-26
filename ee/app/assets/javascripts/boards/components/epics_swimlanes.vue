<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import BoardListHeader from 'ee_else_ce/boards/components/board_list_header.vue';
import { n__ } from '~/locale';
import EpicLane from './epic_lane.vue';
import IssuesLaneList from './issues_lane_list.vue';

export default {
  components: {
    BoardListHeader,
    EpicLane,
    IssuesLaneList,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    lists: {
      type: Array,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
    boardId: {
      type: String,
      required: true,
    },
    canAdminList: {
      type: Boolean,
      required: false,
      default: false,
    },
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
    rootPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['epics', 'isLoadingIssues']),
    ...mapGetters(['unassignedIssues']),
    unassignedIssuesCount() {
      return this.lists.reduce((total, list) => total + this.unassignedIssues(list.id).length, 0);
    },
    unassignedIssuesCountTooltipText() {
      return n__(`%d unassigned issue`, `%d unassigned issues`, this.unassignedIssuesCount);
    },
  },
  mounted() {
    this.fetchIssuesForAllLists();
  },
  methods: {
    ...mapActions(['fetchIssuesForAllLists']),
  },

  emits: [],
};
</script>

<template>
  <div
    class="board-swimlanes gl-white-space-nowrap gl-pb-5 gl-px-3"
    data_qa_selector="board_epics_swimlanes"
  >
    <div
      class="board-swimlanes-headers gl-display-table gl-sticky gl-pt-5 gl-bg-white gl-top-0 gl-z-index-3"
    >
      <div
        v-for="list in lists"
        :key="list.id"
        :class="{
          'is-collapsed': !list.isExpanded,
        }"
        class="board gl-px-3 gl-vertical-align-top gl-white-space-normal"
      >
        <board-list-header
          :can-admin-list="canAdminList"
          :list="list"
          :disabled="disabled"
          :board-id="boardId"
          :is-swimlanes-header="true"
        />
      </div>
    </div>
    <div class="board-epics-swimlanes gl-display-table">
      <epic-lane
        v-for="epic in epics"
        :key="epic.id"
        :epic="epic"
        :lists="lists"
        :is-loading-issues="isLoadingIssues"
        :disabled="disabled"
        :root-path="rootPath"
      />
      <div class="board-lane-unassigned-issues gl-sticky gl-display-inline-block gl-left-0">
        <div class="gl-left-0 gl-py-5 gl-px-3 gl-display-flex gl-align-items-center">
          <span
            class="gl-mr-3 gl-font-weight-bold gl-white-space-nowrap gl-text-overflow-ellipsis gl-overflow-hidden"
          >
            {{ __('Issues with no epic assigned') }}
          </span>
          <span
            v-gl-tooltip.hover
            :title="unassignedIssuesCountTooltipText"
            class="gl-display-flex gl-align-items-center gl-text-gray-500"
            tabindex="0"
            :aria-label="unassignedIssuesCountTooltipText"
            data-testid="issues-lane-issue-count"
          >
            <gl-icon class="gl-mr-2 gl-flex-shrink-0" name="issues" aria-hidden="true" />
            <span aria-hidden="true">{{ unassignedIssuesCount }}</span>
          </span>
        </div>
      </div>
      <div class="gl-display-flex">
        <issues-lane-list
          v-for="list in lists"
          :key="`${list.id}-issues`"
          :list="list"
          :issues="unassignedIssues(list.id)"
          :group-id="groupId"
          :is-unassigned-issues-lane="true"
          :is-loading="isLoadingIssues"
          :disabled="disabled"
          :root-path="rootPath"
        />
      </div>
    </div>
  </div>
</template>
