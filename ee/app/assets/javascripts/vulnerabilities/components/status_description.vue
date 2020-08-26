<script>
import { GlLink, GlSprintf, GlSkeletonLoading, GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';

export default {
  components: {
    GlLink,
    GlSprintf,
    TimeAgoTooltip,
    GlSkeletonLoading,
    GlLoadingIcon,
    UserAvatarLink,
  },

  props: {
    vulnerability: {
      type: Object,
      required: true,
    },
    user: {
      type: Object,
      required: false,
      default: undefined,
    },
    isLoadingVulnerability: {
      type: Boolean,
      required: true,
    },
    isLoadingUser: {
      type: Boolean,
      required: true,
    },
  },

  computed: {
    time() {
      const { state } = this.vulnerability;
      return state === 'detected'
        ? this.vulnerability.pipeline.created_at
        : this.vulnerability[`${this.vulnerability.state}_at`];
    },

    statusText() {
      const { state } = this.vulnerability;

      switch (state) {
        case 'detected':
          return s__('VulnerabilityManagement|Detected %{timeago} in pipeline %{pipelineLink}');
        case 'confirmed':
          return s__('VulnerabilityManagement|Confirmed %{timeago} by %{user}');
        case 'dismissed':
          return s__('VulnerabilityManagement|Dismissed %{timeago} by %{user}');
        case 'resolved':
          return s__('VulnerabilityManagement|Resolved %{timeago} by %{user}');
        default:
          return '%timeago';
      }
    },
  },

  emits: [],
};
</script>

<template>
  <span>
    <gl-skeleton-loading v-if="isLoadingVulnerability" :lines="2" class="h-auto" />
    <gl-sprintf v-else :message="statusText">
      <template #timeago>
        <time-ago-tooltip ref="timeAgo" :time="time" />
      </template>
      <template #user>
        <gl-loading-icon v-if="isLoadingUser" class="d-inline ml-1" />
        <user-avatar-link
          v-else-if="user"
          :link-href="user.user_path"
          :img-src="user.avatar_url"
          :img-size="24"
          :username="user.name"
          :data-user-id="user.id"
          class="font-weight-bold js-user-link"
          img-css-classes="avatar-inline"
        />
      </template>
      <template v-if="vulnerability.pipeline" #pipelineLink>
        <gl-link :href="vulnerability.pipeline.url" target="_blank" class="link">
          {{ vulnerability.pipeline.id }}
        </gl-link>
      </template>
    </gl-sprintf>
  </span>
</template>
