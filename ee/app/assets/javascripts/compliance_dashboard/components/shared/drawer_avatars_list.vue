<script>
import { GlAvatar, GlAvatarsInline, GlAvatarLink } from '@gitlab/ui';
import { DRAWER_AVATAR_SIZE, DRAWER_MAXIMUM_AVATARS } from '../../constants';
import DrawerSectionSubHeader from './drawer_section_sub_header.vue';

export default {
  components: {
    DrawerSectionSubHeader,
    GlAvatar,
    GlAvatarsInline,
    GlAvatarLink,
  },
  props: {
    avatars: {
      type: Array,
      required: false,
      default: () => [],
    },
    header: {
      type: String,
      required: false,
      default: '',
    },
    emptyHeader: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    isEmpty() {
      return !this.avatars.length;
    },
    headerText() {
      if (this.isEmpty) {
        return this.emptyHeader;
      }

      return this.header;
    },
  },
  DRAWER_AVATAR_SIZE,
  DRAWER_MAXIMUM_AVATARS,
};
</script>
<template>
  <div>
    <drawer-section-sub-header v-if="headerText" :is-empty="isEmpty">
      {{ headerText }}
    </drawer-section-sub-header>
    <gl-avatars-inline
      v-if="!isEmpty"
      :avatars="avatars"
      :max-visible="$options.DRAWER_MAXIMUM_AVATARS"
      :avatar-size="$options.DRAWER_AVATAR_SIZE"
      class="gl-flex-wrap gl-w-full!"
      badge-tooltip-prop="name"
    >
      <template #avatar="{ avatar }">
        <gl-avatar-link
          target="blank"
          :href="avatar.web_url"
          :title="avatar.name"
          class="js-user-link"
          :data-user-id="avatar.id"
          :data-name="avatar.name"
        >
          <gl-avatar
            :src="avatar.avatar_url"
            :entity-name="avatar.name"
            :size="$options.DRAWER_AVATAR_SIZE"
          />
        </gl-avatar-link>
      </template>
    </gl-avatars-inline>
  </div>
</template>
