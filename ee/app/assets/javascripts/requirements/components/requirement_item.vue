<script>
import { escape } from 'lodash';
import { GlPopover, GlLink, GlAvatar, GlButton, GlTooltipDirective } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { getTimeago } from '~/lib/utils/datetime_utility';
import timeagoMixin from '~/vue_shared/mixins/timeago';

import RequirementStatusBadge from './requirement_status_badge.vue';

import { FilterState } from '../constants';

export default {
  components: {
    GlPopover,
    GlLink,
    GlAvatar,
    GlButton,
    RequirementStatusBadge,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  props: {
    requirement: {
      type: Object,
      required: true,
      validator: value =>
        [
          'iid',
          'state',
          'userPermissions',
          'title',
          'createdAt',
          'updatedAt',
          'author',
          'testReports',
        ].every(prop => value[prop]),
    },
    stateChangeRequestActive: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    reference() {
      return `REQ-${this.requirement.iid}`;
    },
    canUpdate() {
      return this.requirement.userPermissions.updateRequirement;
    },
    canArchive() {
      return this.requirement.userPermissions.adminRequirement;
    },
    createdAt() {
      return sprintf(__('created %{timeAgo}'), {
        timeAgo: escape(getTimeago().format(this.requirement.createdAt)),
      });
    },
    updatedAt() {
      return sprintf(__('updated %{timeAgo}'), {
        timeAgo: escape(getTimeago().format(this.requirement.updatedAt)),
      });
    },
    isArchived() {
      return this.requirement?.state === FilterState.archived;
    },
    author() {
      return this.requirement.author;
    },
    testReport() {
      return this.requirement.testReports.nodes[0];
    },
    showIssuableMetaActions() {
      return Boolean(this.canUpdate || this.canArchive || this.testReport);
    },
  },
  methods: {
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
    handleArchiveClick() {
      this.$emit('archiveClick', {
        iid: this.requirement.iid,
        state: FilterState.archived,
      });
    },
    handleReopenClick() {
      this.$emit('reopenClick', {
        iid: this.requirement.iid,
        state: FilterState.opened,
      });
    },
  },
};
</script>

<template>
  <li class="issue requirement" :class="{ 'disabled-content': stateChangeRequestActive }">
    <div class="issue-box">
      <div class="issuable-info-container">
        <span class="issuable-reference text-muted d-none d-sm-block mr-2">{{ reference }}</span>
        <div class="issuable-main-info">
          <span class="issuable-reference text-muted d-block d-sm-none">{{ reference }}</span>
          <div class="issue-title title">
            <span class="issue-title-text">{{ requirement.title }}</span>
          </div>
          <div class="issuable-info d-none d-sm-inline-block">
            <span class="issuable-authored">
              <span
                v-gl-tooltip:tooltipcontainer.bottom
                :title="tooltipTitle(requirement.createdAt)"
                >{{ createdAt }}</span
              >
              {{ __('by') }}
              <gl-link ref="authorLink" class="author-link js-user-link" :href="author.webUrl">
                <span class="author">{{ author.name }}</span>
              </gl-link>
            </span>
            <span
              v-gl-tooltip:tooltipcontainer.bottom
              :title="tooltipTitle(requirement.updatedAt)"
              class="issuable-updated-at"
              >&middot; {{ updatedAt }}</span
            >
          </div>
          <requirement-status-badge
            v-if="testReport"
            :test-report="testReport"
            class="d-block d-sm-none"
          />
        </div>
        <div class="d-flex">
          <ul v-if="showIssuableMetaActions" class="controls flex-column flex-sm-row">
            <requirement-status-badge
              v-if="testReport"
              :test-report="testReport"
              element-type="li"
              class="d-none d-sm-block"
            />
            <li v-if="canUpdate && !isArchived" class="requirement-edit d-sm-block">
              <gl-button
                v-gl-tooltip
                icon="pencil"
                :title="__('Edit')"
                @click="$emit('editClick', requirement)"
              />
            </li>
            <li v-if="canArchive && !isArchived" class="requirement-archive d-sm-block">
              <gl-button
                v-if="!stateChangeRequestActive"
                v-gl-tooltip
                icon="archive"
                :loading="stateChangeRequestActive"
                :title="__('Archive')"
                @click="handleArchiveClick"
              />
            </li>
            <li v-if="canArchive && isArchived" class="requirement-reopen d-sm-block">
              <gl-button :loading="stateChangeRequestActive" @click="handleReopenClick">{{
                __('Reopen')
              }}</gl-button>
            </li>
          </ul>
        </div>
      </div>
    </div>
    <gl-popover :target="getAuthorPopoverTarget()" triggers="hover focus" placement="top">
      <div class="gl-line-height-normal gl-display-flex">
        <div class="gl-p-2 gl-flex-shrink-1">
          <gl-avatar :entity-name="author.name" :alt="author.name" :src="author.avatarUrl" />
        </div>
        <div class="gl-p-2 gl-w-full">
          <h5 class="gl-m-0">{{ author.name }}</h5>
          <div class="gl-text-gray-500 gl-mb-3">@{{ author.username }}</div>
        </div>
      </div>
    </gl-popover>
  </li>
</template>
