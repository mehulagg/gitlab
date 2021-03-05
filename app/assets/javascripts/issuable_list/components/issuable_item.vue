<script>
import { GlLink, GlIcon, GlLabel, GlFormCheckbox, GlTooltipDirective } from '@gitlab/ui';

import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { issueHealthStatus, issueHealthStatusCSSMapping } from '~/issue_show/constants';
import { isScopedLabel } from '~/lib/utils/common_utils';
import {
  dateInWords,
  getTimeago,
  getTimeRemainingInWords,
  isInFuture,
  isInPast,
  isToday,
} from '~/lib/utils/datetime_utility';
import { convertToCamelCase } from '~/lib/utils/text_utility';
import { isExternal, setUrlFragment } from '~/lib/utils/url_utility';
import { __, n__, sprintf } from '~/locale';
import IssuableAssignees from '~/vue_shared/components/issue/issue_assignees.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlLink,
    GlIcon,
    GlLabel,
    GlFormCheckbox,
    IssuableAssignees,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  props: {
    issuableSymbol: {
      type: String,
      required: true,
    },
    issuable: {
      type: Object,
      required: true,
    },
    enableLabelPermalinks: {
      type: Boolean,
      required: true,
    },
    labelFilterParam: {
      type: String,
      required: false,
      default: 'label_name',
    },
    showCheckbox: {
      type: Boolean,
      required: true,
    },
    checked: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    author() {
      return this.issuable.author;
    },
    webUrl() {
      return this.issuable.gitlabWebUrl || this.issuable.webUrl;
    },
    authorId() {
      return getIdFromGraphQLId(`${this.author.id}`);
    },
    isIssuableUrlExternal() {
      return isExternal(this.webUrl);
    },
    labels() {
      return this.issuable.labels?.nodes || this.issuable.labels || [];
    },
    assignees() {
      return this.issuable.assignees || [];
    },
    createdAt() {
      return sprintf(__('created %{timeAgo}'), {
        timeAgo: getTimeago().format(this.issuable.createdAt),
      });
    },
    updatedAt() {
      return sprintf(__('updated %{timeAgo}'), {
        timeAgo: getTimeago().format(this.issuable.updatedAt),
      });
    },
    issuableTitleProps() {
      if (this.isIssuableUrlExternal) {
        return {
          target: '_blank',
        };
      }
      return {};
    },
    taskStatus() {
      const { completedCount, count } = this.issuable.taskCompletionStatus || {};
      if (!count) {
        return undefined;
      }

      const text = n__(
        '%{completedCount} of %d task completed',
        '%{completedCount} of %d tasks completed',
        count,
      );
      return sprintf(text, { completedCount });
    },
    milestoneDate() {
      if (this.issuable.milestone?.dueDate) {
        const { dueDate, startDate } = this.issuable.milestone;
        const date = dateInWords(new Date(dueDate), true);
        const remainingTime = this.milestoneRemainingTime(dueDate, startDate);
        return `${date} (${remainingTime})`;
      }
      return __('Milestone');
    },
    dueDate() {
      return this.issuable.dueDate ? dateInWords(new Date(this.issuable.dueDate), true) : undefined;
    },
    isDueDateInPast() {
      return isInPast(new Date(this.issuable.dueDate));
    },
    healthStatusClass() {
      return this.issuable.healthStatus
        ? issueHealthStatusCSSMapping[convertToCamelCase(this.issuable.healthStatus)]
        : '';
    },
    healthStatusText() {
      return this.issuable.healthStatus
        ? issueHealthStatus[convertToCamelCase(this.issuable.healthStatus)]
        : '';
    },
    timeEstimate() {
      return this.issuable.timeStats?.humanTimeEstimate;
    },
    notesCount() {
      return this.issuable.userDiscussionsCount ?? this.issuable.userNotesCount;
    },
    showDiscussions() {
      return typeof this.notesCount === 'number';
    },
    showIssuableMeta() {
      return Boolean(
        this.hasSlotContents('status') || this.showDiscussions || this.issuable.assignees,
      );
    },
    issuableNotesLink() {
      return setUrlFragment(this.webUrl, 'notes');
    },
  },
  methods: {
    hasSlotContents(slotName) {
      return Boolean(this.$slots[slotName]);
    },
    scopedLabel(label) {
      return isScopedLabel(label);
    },
    labelTitle(label) {
      return label.title || label.name;
    },
    labelTarget(label) {
      if (this.enableLabelPermalinks) {
        const value = encodeURIComponent(this.labelTitle(label));
        return `?${this.labelFilterParam}[]=${value}`;
      }
      return '#';
    },
    /**
     * This is needed as an independent method since
     * when user changes current page, `$refs.authorLink`
     * will be null until next page results are loaded & rendered.
     */
    getAuthorPopoverTarget() {
      if (this.$refs.authorLink) {
        return this.$refs.authorLink.$el;
      }
      return '';
    },
    milestoneRemainingTime(dueDate, startDate) {
      const due = new Date(dueDate);
      const start = new Date(startDate);

      if (dueDate && isInPast(due)) {
        return __('Past due');
      } else if (dueDate && isToday(due)) {
        return __('Today');
      } else if (startDate && isInFuture(start)) {
        return __('Upcoming');
      } else if (dueDate) {
        return getTimeRemainingInWords(due);
      }
      return '';
    },
  },
};
</script>

<template>
  <li class="issue gl-px-5!">
    <div class="issuable-info-container">
      <div v-if="showCheckbox" class="issue-check">
        <gl-form-checkbox
          class="gl-mr-0"
          :checked="checked"
          @input="$emit('checked-input', $event)"
        />
      </div>
      <div class="issuable-main-info">
        <div data-testid="issuable-title" class="issue-title title">
          <span class="issue-title-text" dir="auto">
            <gl-icon
              v-if="issuable.confidential"
              v-gl-tooltip
              name="eye-slash"
              :title="__('Confidential')"
              :aria-label="__('Confidential')"
            />
            <gl-link :href="webUrl" v-bind="issuableTitleProps"
              >{{ issuable.title
              }}<gl-icon v-if="isIssuableUrlExternal" name="external-link" class="gl-ml-2"
            /></gl-link>
          </span>
          <span
            v-if="taskStatus"
            class="task-status gl-display-none gl-sm-display-inline-block! gl-ml-3"
          >
            {{ taskStatus }}
          </span>
        </div>
        <div class="issuable-info">
          <slot v-if="hasSlotContents('reference')" name="reference"></slot>
          <span v-else data-testid="issuable-reference" class="issuable-reference"
            >{{ issuableSymbol }}{{ issuable.iid }}</span
          >
          <span class="issuable-authored gl-display-none gl-sm-display-inline-block!">
            &middot;
            <span
              v-gl-tooltip:tooltipcontainer.bottom
              data-testid="issuable-created-at"
              :title="tooltipTitle(issuable.createdAt)"
              >{{ createdAt }}</span
            >
            {{ __('by') }}
            <slot v-if="hasSlotContents('author')" name="author"></slot>
            <gl-link
              v-else
              :data-user-id="authorId"
              :data-username="author.username"
              :data-name="author.name"
              :data-avatar-url="author.avatarUrl"
              :href="author.webUrl"
              data-testid="issuable-author"
              class="author-link js-user-link"
            >
              <span class="author">{{ author.name }}</span>
            </gl-link>
          </span>
          <span
            v-if="issuable.milestone"
            class="issuable-milestone gl-display-none gl-sm-display-inline-block! gl-ml-3"
          >
            <gl-link v-gl-tooltip :href="issuable.milestone.webUrl" :title="milestoneDate">
              <gl-icon name="clock" />
              {{ issuable.milestone.title }}
            </gl-link>
          </span>
          <span
            v-if="issuable.dueDate"
            v-gl-tooltip
            class="issuable-due-date gl-display-none gl-sm-display-inline-block! gl-ml-3"
            :class="{ 'gl-text-red-500': isDueDateInPast }"
            :title="__('Due date')"
          >
            <gl-icon name="calendar" />
            {{ dueDate }}
          </span>
          <span
            v-if="issuable.weight != null"
            v-gl-tooltip
            class="issuable-weight gl-display-none gl-sm-display-inline-block! gl-ml-3"
            :title="__('Weight')"
          >
            <gl-icon name="weight" />
            {{ issuable.weight }}
          </span>
          <span v-if="issuable.healthStatus" class="health-status gl-ml-3">
            <span class="gl-label gl-label-sm" :class="[healthStatusClass]">
              <span class="gl-label-text">
                {{ healthStatusText }}
              </span>
            </span>
          </span>
          <slot name="timeframe"></slot>
          <gl-label
            v-for="(label, index) in labels"
            :key="index"
            :background-color="label.color"
            :title="labelTitle(label)"
            :description="label.description"
            :scoped="scopedLabel(label)"
            :target="labelTarget(label)"
            :class="{ 'gl-ml-3': index === 0, 'gl-ml-2': index }"
            size="sm"
          />
          <span
            v-if="timeEstimate"
            v-gl-tooltip
            class="gl-display-none gl-sm-display-inline-block! gl-ml-3"
            :title="__('Estimate')"
          >
            <gl-icon name="timer" />
            {{ timeEstimate }}
          </span>
        </div>
      </div>
      <div class="issuable-meta">
        <ul v-if="showIssuableMeta" class="controls">
          <li v-if="hasSlotContents('status')" class="issuable-status">
            <slot name="status"></slot>
          </li>
          <li v-if="assignees.length" class="gl-display-flex">
            <issuable-assignees
              :assignees="issuable.assignees"
              :icon-size="16"
              :max-visible="4"
              img-css-classes="gl-mr-2!"
              class="gl-align-items-center gl-display-flex gl-ml-3"
            />
          </li>
          <li
            v-if="issuable.mergeRequestsCount > 0"
            v-gl-tooltip
            class="gl-display-none gl-sm-display-block"
            :title="__('Related merge requests')"
          >
            <gl-icon name="merge-request" />
            {{ issuable.mergeRequestsCount }}
          </li>
          <li
            v-if="issuable.upvotes > 0"
            v-gl-tooltip
            class="issuable-upvotes gl-display-none gl-sm-display-block"
            :title="__('Upvotes')"
          >
            <gl-icon name="thumb-up" />
            {{ issuable.upvotes }}
          </li>
          <li
            v-if="issuable.downvotes > 0"
            v-gl-tooltip
            class="issuable-downvotes gl-display-none gl-sm-display-block"
            :title="__('Downvotes')"
          >
            <gl-icon name="thumb-down" />
            {{ issuable.downvotes }}
          </li>
          <li
            v-if="issuable.blockingIssuesCount > 0"
            v-gl-tooltip
            class="blocking-issues gl-display-none gl-sm-display-block"
            :title="__('Blocking issues')"
          >
            <gl-icon name="issue-block" />
            {{ issuable.blockingIssuesCount }}
          </li>
          <li
            v-if="showDiscussions"
            data-testid="issuable-discussions"
            class="issuable-comments gl-display-none gl-sm-display-block"
          >
            <gl-link
              v-gl-tooltip:tooltipcontainer.top
              :title="__('Comments')"
              :href="issuableNotesLink"
              :class="{ 'no-comments': !notesCount }"
              class="gl-reset-color!"
            >
              <gl-icon name="comments" />
              {{ notesCount }}
            </gl-link>
          </li>
        </ul>
        <div
          data-testid="issuable-updated-at"
          class="float-right issuable-updated-at gl-display-none gl-sm-display-inline-block!"
        >
          <span
            v-gl-tooltip:tooltipcontainer.bottom
            :title="tooltipTitle(issuable.updatedAt)"
            class="issuable-updated-at"
            >{{ updatedAt }}</span
          >
        </div>
      </div>
    </div>
  </li>
</template>
