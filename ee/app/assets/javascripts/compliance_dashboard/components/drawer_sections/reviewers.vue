<script>
import {
  GlAvatar,
  GlAvatarsInline,
  GlAvatarLabeled,
  GlAvatarLink,
  GlTooltipDirective,
} from '@gitlab/ui';
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
    GlAvatarLabeled,
    GlAvatarLink,
  },
  props: {
    approvers: {
      type: Array,
      required: false,
      default: () => [],
    },
    commenters: {
      type: Array,
      required: false,
      default: () => [],
    },
    mergedBy: {
      type: Object,
      required: false,
      default: () => {},
    },
  },
  computed: {
    commentersHeaderText() {
      return n__('%d commenter', '%d commenters', this.commenters.length);
    },
    approversHeaderText() {
      return n__('%d approver', '%d approvers', this.approvers.length);
    },
    hasCommenters() {
      return this.commenters.length > 0;
    },
    hasApprovers() {
      return this.approvers.length > 0;
    },
    hasMergedBy() {
      return Boolean(this.mergedBy?.name);
    },
  },
  i18n: {
    header: __('Peer review by'),
    mergedByHeader: __('Merged by'),
  },
  AVATAR_SIZE,
  MAXIMUM_AVATARS,
};
</script>
<template>
  <div>
    <drawer-section-header>{{ $options.i18n.header }}</drawer-section-header>
    <template v-if="hasCommenters">
      <p class="gl-text-gray-500 gl-mb-4">{{ commentersHeaderText }}</p>
      <gl-avatars-inline
        :avatars="commenters"
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
    </template>
    <template v-if="hasApprovers">
      <p class="gl-text-gray-500 gl-mb-4" :class="{ 'gl-mt-4': hasCommenters }">
        {{ approversHeaderText }}
      </p>
      <gl-avatars-inline
        :avatars="approvers"
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
    </template>
    <template v-if="hasMergedBy">
      <p class="gl-text-gray-500 gl-mb-4" :class="{ 'gl-mt-4': hasCommenters || hasApprovers }">
        {{ $options.i18n.mergedByHeader }}
      </p>
      <gl-avatar-link :title="mergedBy.name" :href="mergedBy.web_url">
        <gl-avatar-labeled
          :size="16"
          :entity-name="mergedBy.name"
          label=""
          :sub-label="mergedBy.name"
          :src="mergedBy.avatar_url"
        />
      </gl-avatar-link>
    </template>
  </div>
</template>
