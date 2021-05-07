<script>
import { GlAvatarLink, GlAvatarLabeled, GlLink } from '@gitlab/ui';
import { ListType, ListTypeTitles } from '~/boards/constants';

export default {
  components: {
    GlLink,
    GlAvatarLink,
    GlAvatarLabeled,
  },
  props: {
    boardListType: {
      type: String,
      required: true,
    },
    activeList: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      ListType,
    };
  },
  computed: {
    activeListObject() {
      return this.activeList[this.boardListType];
    },
    listTypeHeader() {
      return ListTypeTitles[this.boardListType] || '';
    },
  },
};
</script>

<template>
  <div>
    <label class="js-list-label gl-display-block">{{ listTypeHeader }}</label>
    <gl-avatar-link
      v-if="boardListType === ListType.assignee"
      class="js-assignee"
      :href="activeListObject.webUrl"
    >
      <gl-avatar-labeled
        :size="32"
        :label="activeListObject.name"
        :sub-label="`@${activeListObject.username}`"
        :src="activeListObject.avatar"
      />
    </gl-avatar-link>
    <gl-link v-else class="js-list-title" :href="activeListObject.webUrl">
      {{ activeListObject.title }}
    </gl-link>
  </div>
</template>
