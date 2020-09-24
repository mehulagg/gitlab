<script>
/* eslint-disable vue/no-v-html */
import { GlLink, GlIcon } from '@gitlab/ui';
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import TotalTime from './total_time_component.vue';
import iconBranch from '../svg/icon_branch.svg';
import iconBuildStatus from '../svg/icon_build_status.svg';

export default {
  components: {
    UserAvatarImage,
    TotalTime,
    GlIcon,
    GlLink,
  },
  props: {
    events: {
      type: Array,
      required: true,
    },
    stage: {
      type: Object,
      required: true,
    },
    withBuildStatus: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    iconBuildStatus() {
      return iconBuildStatus;
    },
    iconBranch() {
      return iconBranch;
    },
  },
};
</script>
<template>
  <ul class="stage-event-list">
    <li
      v-for="({ id, author, url, branch, name, commitUrl, shortSha, date, totalTime }, i) in events"
      :key="i"
      class="stage-event-item item-build-component"
    >
      <div class="item-details">
        <template v-if="!withBuildStatus">
          <user-avatar-image :img-src="author.avatarUrl" />
        </template>
        <h5 class="item-title">
          <template v-if="withBuildStatus">
            <span class="icon-build-status" v-html="iconBuildStatus"></span>
            <gl-link :href="url" class="item-build-name">{{ name }}</gl-link> &middot;
          </template>
          <gl-link :href="url" class="pipeline-id">#{{ id }}</gl-link>
          <gl-icon :size="16" name="fork" />
          <gl-link :href="branch.url" class="ref-name">{{ branch.name }}</gl-link>
          <span class="icon-branch" v-html="iconBranch"></span>
          <gl-link :href="commitUrl" class="commit-sha">{{ shortSha }}</gl-link>
        </h5>
        <span v-if="withBuildStatus">
          <gl-link :href="url" class="issue-date">{{ date }}</gl-link>
        </span>
        <span v-else>
          <gl-link :href="url" class="build-date">{{ date }}</gl-link>
          {{ s__('ByAuthor|by') }}
          <gl-link :href="author.webUrl" class="issue-author-link">{{ author.name }}</gl-link>
        </span>
      </div>
      <div class="item-time">
        <total-time :time="totalTime" />
      </div>
    </li>
  </ul>
</template>
