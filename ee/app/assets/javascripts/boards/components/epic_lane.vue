<script>
import { GlButton, GlIcon, GlLink, GlPopover, GlTooltipDirective } from '@gitlab/ui';
import { mapActions, mapGetters, mapState } from 'vuex';
import createFlash from '~/flash';
import { formatDate } from '~/lib/utils/datetime_utility';
import { __, n__, sprintf } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { statusType } from '../../epic/constants';
import IssuesLaneList from './issues_lane_list.vue';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlPopover,
    IssuesLaneList,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  props: {
    epic: {
      type: Object,
      required: true,
    },
    lists: {
      type: Array,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
    canAdminList: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    const { userPreferences } = this.epic;

    const { collapsed = false } = userPreferences || {};

    return {
      isCollapsed: collapsed,
    };
  },
  computed: {
    ...mapState(['filterParams']),
    ...mapGetters(['getIssuesByEpic']),
    isOpen() {
      return this.epic.state === statusType.open;
    },
    chevronTooltip() {
      return this.isCollapsed ? __('Expand') : __('Collapse');
    },
    chevronIcon() {
      return this.isCollapsed ? 'chevron-right' : 'chevron-down';
    },
    issuesCount() {
      return this.lists.reduce(
        (total, list) => total + this.getIssuesByEpic(list.id, this.epic.id).length,
        0,
      );
    },
    issuesCountTooltipText() {
      return n__(`%d issue in this group`, `%d issues in this group`, this.issuesCount);
    },
    epicTimeAgoString() {
      return this.isOpen
        ? sprintf(__(`Created %{epicTimeagoDate}`), {
            epicTimeagoDate: this.timeFormatted(this.epic.createdAt),
          })
        : sprintf(__(`Closed %{epicTimeagoDate}`), {
            epicTimeagoDate: this.timeFormatted(this.epic.closedAt),
          });
    },
    epicDateString() {
      return formatDate(this.epic.createdAt);
    },
    shouldDisplay() {
      return this.issuesCount > 0;
    },
  },
  methods: {
    ...mapActions(['updateBoardEpicUserPreferences']),
    toggleCollapsed() {
      this.isCollapsed = !this.isCollapsed;

      this.updateBoardEpicUserPreferences({
        collapsed: this.isCollapsed,
        epicId: this.epic.id,
      }).catch(() => {
        createFlash({ message: __('Unable to save your preference'), captureError: true });
      });
    },
  },
};
</script>

<template>
  <div v-if="shouldDisplay">
    <div
      class="board-epic-lane gl-sticky gl-left-0 gl-display-inline-block"
      data-testid="board-epic-lane"
    >
      <div class="gl-pb-5 gl-px-3 gl-display-flex gl-align-items-center">
        <gl-button
          v-gl-tooltip.hover.right
          :aria-label="chevronTooltip"
          :title="chevronTooltip"
          :icon="chevronIcon"
          class="gl-mr-2 gl-cursor-pointer"
          category="tertiary"
          size="small"
          data-testid="epic-lane-chevron"
          @click="toggleCollapsed"
        />
        <h4
          ref="epicTitle"
          class="gl-my-0 gl-mr-3 gl-font-weight-bold gl-font-base gl-white-space-nowrap gl-text-overflow-ellipsis gl-overflow-hidden"
        >
          {{ epic.title }}
        </h4>
        <gl-popover :target="() => $refs.epicTitle" placement="top">
          <template #title>{{ epic.title }} &middot; {{ epic.reference }}</template>
          <div>{{ epicTimeAgoString }}</div>
          <div class="gl-mb-2">{{ epicDateString }}</div>
          <gl-link :href="epic.webUrl" class="gl-font-sm">{{ __('Go to epic') }}</gl-link>
        </gl-popover>
        <span
          v-gl-tooltip.hover
          :title="issuesCountTooltipText"
          class="gl-display-flex gl-align-items-center gl-text-gray-500"
          tabindex="0"
          :aria-label="issuesCountTooltipText"
          data-testid="epic-lane-issue-count"
        >
          <gl-icon class="gl-mr-2 gl-flex-shrink-0" name="issues" />
          <span aria-hidden="true">{{ issuesCount }}</span>
        </span>
      </div>
    </div>
    <div v-if="!isCollapsed" class="gl-display-flex gl-pb-5" data-testid="board-epic-lane-issues">
      <issues-lane-list
        v-for="list in lists"
        :key="`${list.id}-issues`"
        :list="list"
        :issues="getIssuesByEpic(list.id, epic.id)"
        :disabled="disabled"
        :epic-id="epic.id"
        :epic-is-confidential="epic.confidential"
        :can-admin-list="canAdminList"
      />
    </div>
  </div>
</template>
