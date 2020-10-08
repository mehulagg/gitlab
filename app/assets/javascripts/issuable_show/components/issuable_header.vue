<script>
import { GlIcon, GlButton, GlTooltipDirective, GlAvatarLink, GlAvatarLabeled } from '@gitlab/ui';

import { sprintf, __ } from '~/locale';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlIcon,
    GlButton,
    GlAvatarLink,
    GlAvatarLabeled,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  props: {
    createdAt: {
      type: String,
      required: true,
    },
    author: {
      type: Object,
      required: true,
    },
    statusBadgeClass: {
      type: String,
      required: false,
      default: '',
    },
    statusIcon: {
      type: String,
      required: false,
      default: '',
    },
    blocked: {
      type: Boolean,
      required: false,
      default: false,
    },
    confidential: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    createdAtText() {
      return sprintf(__('Opened %{timeAgo}'), {
        timeAgo: getTimeago().format(this.createdAt),
      });
    },
    authorId() {
      return getIdFromGraphQLId(`${this.author.id}`);
    },
  },
  methods: {
    handleRightSidebarToggleClick() {
      const toggleSidebarButtonEl = document.querySelector('.js-toggle-right-sidebar-button');

      if (toggleSidebarButtonEl) {
        toggleSidebarButtonEl.dispatchEvent(new Event('click'));
      }
    },
  },
};
</script>

<template>
  <div class="detail-page-header">
    <div class="detail-page-header-body">
      <div data-testid="status" class="issuable-status-box status-box" :class="statusBadgeClass">
        <gl-icon v-if="statusIcon" :name="statusIcon" class="d-block d-sm-none" />
        <span class="d-none d-sm-block"><slot name="status-badge"></slot></span>
      </div>
      <div class="issuable-meta gl-display-flex gl-align-items-center">
        <div class="gl-display-inline-block">
          <div v-if="blocked" data-testid="blocked" class="issuable-warning-icon inline">
            <gl-icon name="lock" />
          </div>
          <div v-if="confidential" data-testid="confidential" class="issuable-warning-icon inline">
            <gl-icon name="eye-slash" />
          </div>
        </div>
        <span>
          <span v-gl-tooltip:tooltipcontainer.bottom :title="tooltipTitle(createdAt)">{{
            createdAtText
          }}</span>
          {{ __('by') }}
        </span>
        <gl-avatar-link
          data-testid="avatar"
          :data-user-id="authorId"
          :data-username="author.username"
          :data-name="author.name"
          :href="author.webUrl"
          target="_blank"
          class="js-user-link gl-ml-3 d-none d-sm-inline-flex"
        >
          <gl-avatar-labeled :size="24" :src="author.avatarUrl" :label="author.name" />
        </gl-avatar-link>
        <gl-avatar-link
          data-testid="avatar-username"
          :data-user-id="authorId"
          :data-username="author.username"
          :data-name="author.name"
          :href="author.webUrl"
          target="_blank"
          class="js-user-link gl-ml-2 d-sm-none d-inline"
        >
          <strong class="author">@{{ author.username }}</strong>
        </gl-avatar-link>
      </div>
      <gl-button
        data-testid="sidebar-toggle"
        icon="chevron-double-lg-left"
        class="d-block d-sm-none gutter-toggle issuable-gutter-toggle"
        @click="handleRightSidebarToggleClick"
      />
    </div>
    <div
      data-testid="header-actions"
      class="detail-page-header-actions js-issuable-actions js-issuable-buttons gl-display-flex gl-display-md-block"
    >
      <slot name="header-actions"></slot>
    </div>
  </div>
</template>
