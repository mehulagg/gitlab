<script>
import {
  GlAvatarLink,
  GlAvatarLabeled,
  GlBadge,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import { __ } from '~/locale';
import { AVATAR_SIZE } from '../constants';

export default {
  name: 'UserAvatar',
  avatarSize: AVATAR_SIZE,
  orphanedUserLabel: __('Orphaned member'),
  components: {
    GlAvatarLink,
    GlAvatarLabeled,
    GlBadge,
  },
  directives: {
    SafeHtml,
  },
  props: {
    member: {
      type: Object,
      required: true,
    },
    isCurrentUser: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    user() {
      return this.member.user;
    },
    badges() {
      return [
        {
          id: 1,
          show: this.isCurrentUser,
          text: __("It's you"),
          variant: 'success',
        },
        {
          id: 2,
          show: this.member.usingLicense,
          text: __('Is using seat'),
          variant: 'neutral',
        },
        {
          id: 3,
          show: this.user?.blocked,
          text: __('Blocked'),
          variant: 'danger',
        },
        {
          id: 4,
          show: this.user?.twoFactorEnabled,
          text: __('2FA'),
          variant: 'info',
        },
        {
          id: 5,
          show: this.member.groupSso,
          text: __('SAML'),
          variant: 'info',
        },
        {
          id: 6,
          show: this.member.groupManagedAccount,
          text: __('Managed Account'),
          variant: 'info',
        },
      ];
    },
    filteredBadges() {
      return this.badges.filter(badge => badge.show);
    },
  },
};
</script>

<template>
  <gl-avatar-link
    v-if="user"
    class="js-user-link"
    :href="user.webUrl"
    :data-user-id="user.id"
    :data-username="user.username"
  >
    <gl-avatar-labeled
      :label="user.name"
      :sub-label="`@${user.username}`"
      :src="user.avatarUrl"
      :alt="user.name"
      :size="$options.avatarSize"
      :entity-name="user.name"
      :entity-id="user.id"
    >
      <template #meta>
        <div v-for="badge in filteredBadges" :key="badge.id" class="gl-p-1">
          <gl-badge size="sm" :variant="badge.variant">
            {{ badge.text }}
          </gl-badge>
        </div>
      </template>
    </gl-avatar-labeled>
  </gl-avatar-link>

  <gl-avatar-labeled
    v-else
    :label="$options.orphanedUserLabel"
    :alt="$options.orphanedUserLabel"
    :size="$options.avatarSize"
    :entity-name="$options.orphanedUserLabel"
    :entity-id="member.id"
  />
</template>
