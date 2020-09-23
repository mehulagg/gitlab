<script>
import { GlLink } from '@gitlab/ui';
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import TotalTime from './total_time_component.vue';

export default {
  components: {
    GlLink,
    UserAvatarImage,
    TotalTime,
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
  },
  methods: {
    isMrLink(url = '') {
      return url.includes('/merge_request');
    },
  },
};
</script>
<template>
  <ul class="stage-event-list">
    <li
      v-for="({ iid, title, url, author, totalTime, createdAt }, i) in events"
      :key="i"
      class="stage-event-item"
    >
      <div class="item-details">
        <user-avatar-image
          :img-src="author.avatarUrl"
          :alt="
            sprintf(__('Merge request %{iid} authored by %{authorName}'), {
              iid,
              authorName: author.name,
            })
          "
        />
        <h5 class="item-title issue-title">
          <gl-link :href="url" class="issue-title">{{ title }}</gl-link>
        </h5>
        <template v-if="isMrLink(url)">
          <gl-link :href="url" class="mr-link">!{{ iid }}</gl-link>
        </template>
        <template v-else>
          <gl-link :href="url" class="issue-link">#{{ iid }}</gl-link>
        </template>
        &middot;
        <span>
          {{ s__('OpenedNDaysAgo|Opened') }}
          <gl-link :href="url" class="issue-date">{{ createdAt }}</gl-link>
        </span>
        <span>
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
