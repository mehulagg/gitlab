<script>
import { GlAvatarLink, GlAvatarLabeled, GlAvatar, GlTooltipDirective } from '@gitlab/ui';
import { __, sprintf } from '~/locale';

const DEFAULT_RENDER_COUNT = 5;

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlAvatarLink,
    GlAvatarLabeled,
    GlAvatar,
  },
  props: {
    users: {
      type: Array,
      required: true,
    },
    issuableType: {
      type: String,
      required: false,
      default: 'issue',
    },
  },
  data() {
    return {
      showLess: true,
    };
  },
  computed: {
    firstUser() {
      return this.users[0];
    },
    hasOneUser() {
      return this.users.length === 1;
    },
    hiddenAssigneesLabel() {
      const { numberOfHiddenAssignees } = this;
      return sprintf(__('+ %{numberOfHiddenAssignees} more'), { numberOfHiddenAssignees });
    },
    renderShowMoreSection() {
      return this.users.length > DEFAULT_RENDER_COUNT;
    },
    numberOfHiddenAssignees() {
      return this.users.length - DEFAULT_RENDER_COUNT;
    },
    uncollapsedUsers() {
      const uncollapsedLength = this.showLess
        ? Math.min(this.users.length, DEFAULT_RENDER_COUNT)
        : this.users.length;
      return this.showLess ? this.users.slice(0, uncollapsedLength) : this.users;
    },
    username() {
      return `@${this.firstUser.username}`;
    },
  },
  methods: {
    toggleShowLess() {
      this.showLess = !this.showLess;
    },
    avatarUrl(user) {
      return user.avatarUrl || user.avatar || user.avatar_url || gon.default_avatar_url;
    },
    userName(name) {
      return `@${name}`;
    },
  },
};
</script>

<template>
  <gl-avatar-link v-if="hasOneUser">
    <gl-avatar-labeled
      :size="32"
      :label="firstUser.name"
      :sub-label="userName(firstUser.username)"
      :src="avatarUrl(firstUser)"
    />
  </gl-avatar-link>
  <div v-else>
    <div class="user-list">
      <div v-for="user in uncollapsedUsers" :key="user.id" class="user-item">
        <gl-avatar-link :href="user.webUrl || user.web_url">
          <gl-avatar v-gl-tooltip="user.name" :size="32" :src="avatarUrl(user)" />
        </gl-avatar-link>
      </div>
    </div>
    <div v-if="renderShowMoreSection" class="user-list-more">
      <button
        type="button"
        class="btn-link"
        data-qa-selector="more_assignees_link"
        @click="toggleShowLess"
      >
        <template v-if="showLess">
          {{ hiddenAssigneesLabel }}
        </template>
        <template v-else>{{ __('- show less') }}</template>
      </button>
    </div>
  </div>
</template>
