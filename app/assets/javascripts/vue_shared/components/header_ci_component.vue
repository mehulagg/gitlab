<script>
/* eslint-disable vue/no-v-html */
import { GlTooltipDirective, GlLink, GlDeprecatedButton } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import CiIconBadge from './ci_badge_link.vue';
import TimeagoTooltip from './time_ago_tooltip.vue';
import UserAvatarImage from './user_avatar/user_avatar_image.vue';
import { glEmojiTag } from '../../emoji';

/**
 * Renders header component for job and pipeline page based on UI mockups
 *
 * Used in:
 * - job show page
 * - pipeline show page
 */
export default {
  components: {
    CiIconBadge,
    TimeagoTooltip,
    UserAvatarImage,
    GlLink,
    GlDeprecatedButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    status: {
      type: Object,
      required: true,
    },
    itemName: {
      type: String,
      required: true,
    },
    itemId: {
      type: Number,
      required: true,
    },
    time: {
      type: String,
      required: true,
    },
    user: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    hasSidebarButton: {
      type: Boolean,
      required: false,
      default: false,
    },
    shouldRenderTriggeredLabel: {
      type: Boolean,
      required: false,
      default: true,
    },
  },

  computed: {
    userAvatarAltText() {
      return sprintf(__(`%{username}'s avatar`), { username: this.user.name });
    },
    userPath() {
      // GraphQL returns `webPath` and Rest `path`
      return this.user?.webPath || this.user?.path;
    },
    avatarUrl() {
      // GraphQL returns `avatarUrl` and Rest `avatar_url`
      return this.user?.avatarUrl || this.user?.avatar_url;
    },
    statusTooltipHTML() {
      // GraphQL returns `status.message` and Rest `status_tooltip_html`
      const { message, emoji } = this.user?.status || {};
      const emojiHtml = emoji ? glEmojiTag(emoji) : '';
      const statusMessage = `${emojiHtml}${message || ''}`;

      return statusMessage || this.user?.status_tooltip_html;
    },
  },

  methods: {
    onClickSidebarButton() {
      this.$emit('clickedSidebarButton');
    },
  },
};
</script>

<template>
  <header class="page-content-header ci-header-container" data-testid="pipeline-header-content">
    <section class="header-main-content">
      <ci-icon-badge :status="status" />

      <strong> {{ itemName }} #{{ itemId }} </strong>

      <template v-if="shouldRenderTriggeredLabel">{{ __('triggered') }}</template>
      <template v-else>{{ __('created') }}</template>

      <timeago-tooltip :time="time" />

      {{ __('by') }}

      <template v-if="user">
        <gl-link
          v-gl-tooltip
          :href="userPath"
          :title="user.email"
          class="js-user-link commit-committer-link"
        >
          <user-avatar-image
            :img-src="avatarUrl"
            :img-alt="userAvatarAltText"
            :tooltip-text="user.name"
            :img-size="24"
          />

          {{ user.name }}
        </gl-link>
        <span v-if="statusTooltipHTML" v-html="statusTooltipHTML"></span>
      </template>
    </section>

    <section v-if="$slots.default" data-testid="headerButtons" class="gl-display-flex">
      <slot></slot>
    </section>
    <gl-deprecated-button
      v-if="hasSidebarButton"
      id="toggleSidebar"
      class="d-block d-sm-none
sidebar-toggle-btn js-sidebar-build-toggle js-sidebar-build-toggle-header"
      @click="onClickSidebarButton"
    >
      <i class="fa fa-angle-double-left" aria-hidden="true" aria-labelledby="toggleSidebar"> </i>
    </gl-deprecated-button>
  </header>
</template>
