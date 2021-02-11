<script>
import { GlButton, GlTooltipDirective, GlIcon } from '@gitlab/ui';
import ReviewerAvatarLink from './reviewer_avatar_link.vue';

export default {
  components: {
    GlButton,
    GlIcon,
    ReviewerAvatarLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    users: {
      type: Array,
      required: true,
    },
    rootPath: {
      type: String,
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
      loadingStates: {},
    };
  },
  watch: {
    users: {
      handler(users) {
        this.loadingStates = users.reduce(
          (acc, user) => ({
            ...acc,
            [user.id]: acc[user.id] || null,
          }),
          this.loadingStates,
        );
      },
      immediate: true,
    },
  },
  methods: {
    toggleShowLess() {
      this.showLess = !this.showLess;
    },
    reRequestReview(userId) {
      this.loadingStates[userId] = 'loading';
      this.$emit('request-review', { userId, callback: this.requestReviewComplete });
    },
    requestReviewComplete(userId, success) {
      if (success) {
        this.loadingStates[userId] = 'success';

        setTimeout(() => {
          this.loadingStates[userId] = null;
        }, 1500);
      } else {
        this.loadingStates[userId] = null;
      }
    },
  },
};
</script>

<template>
  <div>
    <div
      v-for="(user, index) in users"
      :key="user.id"
      :class="{ 'gl-mb-3': index !== users.length - 1 }"
      data-testid="reviewer"
    >
      <reviewer-avatar-link :user="user" :root-path="rootPath" :issuable-type="issuableType">
        <div class="gl-ml-3">@{{ user.username }}</div>
      </reviewer-avatar-link>
      <gl-icon
        v-if="loadingStates[user.id] === 'success'"
        :size="24"
        name="check"
        class="float-right gl-text-green-500"
        data-testid="re-request-success"
      />
      <gl-button
        v-else-if="user.can_update_merge_request && user.reviewed"
        v-gl-tooltip.left
        :title="__('Re-request review')"
        :loading="loadingStates[user.id] === 'loading'"
        class="float-right gl-text-gray-500!"
        size="small"
        icon="redo"
        variant="link"
        data-testid="re-request-button"
        @click="reRequestReview(user.id)"
      />
    </div>
  </div>
</template>
