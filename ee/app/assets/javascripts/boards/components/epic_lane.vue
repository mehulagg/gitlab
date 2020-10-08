<script>
import { GlButton, GlIcon, GlLink, GlPopover, GlTooltipDirective } from '@gitlab/ui';
import { mapGetters } from 'vuex';
import { __, n__, sprintf } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { formatDate } from '~/lib/utils/datetime_utility';
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
    isLoadingIssues: {
      type: Boolean,
      required: false,
      default: false,
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
    return {
      isExpanded: true,
    };
  },
  computed: {
    ...mapGetters(['getIssuesByEpic']),
    isOpen() {
      return this.epic.state === statusType.open;
    },
    chevronTooltip() {
      return this.isExpanded ? __('Collapse') : __('Expand');
    },
    chevronIcon() {
      return this.isExpanded ? 'chevron-down' : 'chevron-right';
    },
    stateText() {
      return this.isOpen ? __('Opened') : __('Closed');
    },
    epicIcon() {
      return this.isOpen ? 'epic' : 'epic-closed';
    },
    stateIconClass() {
      return this.isOpen ? 'gl-text-green-500' : 'gl-text-blue-500';
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
        ? sprintf(__(`Opened %{epicTimeagoDate}`), {
            epicTimeagoDate: this.timeFormatted(this.epic.createdAt),
          })
        : sprintf(__(`Closed %{epicTimeagoDate}`), {
            epicTimeagoDate: this.timeFormatted(this.epic.closedAt),
          });
    },
    epicDateString() {
      return formatDate(this.epic.createdAt);
    },
  },
  methods: {
    toggleExpanded() {
      this.isExpanded = !this.isExpanded;
    },
  },
};
</script>

<template>
  <div>
    <div class="board-epic-lane gl-sticky gl-left-0 gl-display-inline-block">
      <div class="gl-py-5 gl-px-3 gl-display-flex gl-align-items-center">
        <gl-button
          v-gl-tooltip.hover.right
          :aria-label="chevronTooltip"
          :title="chevronTooltip"
          :icon="chevronIcon"
          class="gl-mr-2 gl-cursor-pointer"
          variant="link"
          data-testid="epic-lane-chevron"
          @click="toggleExpanded"
        />
        <gl-icon
          class="gl-mr-2 gl-flex-shrink-0"
          :class="stateIconClass"
          :name="epicIcon"
          :aria-label="stateText"
        />
        <h4
          ref="epicTitle"
          class="gl-mr-3 gl-font-weight-bold gl-font-base gl-white-space-nowrap gl-text-overflow-ellipsis gl-overflow-hidden"
        >
          {{ epic.title }}
        </h4>
        <gl-popover :target="() => $refs.epicTitle" triggers="hover" placement="top">
          <template #title
            >{{ epic.title }} &middot; {{ epic.reference }}</template
          >
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
          <gl-icon class="gl-mr-2 gl-flex-shrink-0" name="issues" aria-hidden="true" />
          <span aria-hidden="true">{{ issuesCount }}</span>
        </span>
      </div>
    </div>
    <div v-if="isExpanded" class="gl-display-flex">
      <issues-lane-list
        v-for="list in lists"
        :key="`${list.id}-issues`"
        :list="list"
        :issues="getIssuesByEpic(list.id, epic.id)"
        :is-loading="isLoadingIssues"
        :disabled="disabled"
        :epic-id="epic.id"
        :epic-is-confidential="epic.confidential"
        :can-admin-list="canAdminList"
      />
    </div>
  </div>
</template>
