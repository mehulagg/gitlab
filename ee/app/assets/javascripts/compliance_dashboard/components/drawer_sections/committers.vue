<script>
import { GlAvatar, GlAvatarsInline, GlAvatarLink, GlTooltipDirective } from '@gitlab/ui';
import { __, n__ } from '~/locale';
import DrawerSectionHeader from '../shared/drawer_section_header.vue';

const AVATAR_SIZE = 24;
const MAXIMUM_AVATARS = 20;

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    DrawerSectionHeader,
    GlAvatar,
    GlAvatarsInline,
    GlAvatarLink,
  },
  props: {
    committers: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    committersHeaderText() {
      return n__('%d commit author', '%d commit authors', this.committers.length);
    },
  },
  i18n: {
    header: __('Change made by'),
  },
  AVATAR_SIZE,
  MAXIMUM_AVATARS,
};
</script>
<template>
  <div>
    <drawer-section-header>{{ $options.i18n.header }}</drawer-section-header>
    <p class="gl-text-gray-500 gl-mb-4" data-testid="committers-sub-header">{{ committersHeaderText }}</p>
    <gl-avatars-inline
      :avatars="committers"
      :max-visible="$options.MAXIMUM_AVATARS"
      :avatar-size="$options.AVATAR_SIZE"
      class="gl-flex-wrap gl-w-full!"
      badge-tooltip-prop="name"
    >
      <template #avatar="{ avatar }">
        <gl-avatar-link
          v-gl-tooltip
          target="blank"
          :href="avatar.web_url"
          :title="avatar.name"
          class="gl-text-gray-500 author-link js-user-link"
        >
          <gl-avatar
            :src="avatar.avatar_url"
            :entity-id="avatar.id"
            :entity-name="avatar.name"
            :size="$options.AVATAR_SIZE"
          />
        </gl-avatar-link>
      </template>
    </gl-avatars-inline>
  </div>
</template>
