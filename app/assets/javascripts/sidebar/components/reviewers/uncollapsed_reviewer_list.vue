<script>
// NOTE! For the first iteration, we are simply copying the implementation of Assignees
// It will soon be overhauled in Issue https://gitlab.com/gitlab-org/gitlab/-/issues/233736
import { GlButton } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import ReviewerAvatarLink from './reviewer_avatar_link.vue';

const DEFAULT_RENDER_COUNT = 5;

export default {
  components: {
    GlButton,
    ReviewerAvatarLink,
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
    };
  },
  computed: {
    firstUser() {
      return this.users[0];
    },
    hasOneUser() {
      return this.users.length === 1;
    },
    hiddenReviewersLabel() {
      const { numberOfHiddenReviewers } = this;
      return sprintf(__('+ %{numberOfHiddenReviewers} more'), { numberOfHiddenReviewers });
    },
    renderShowMoreSection() {
      return this.users.length > DEFAULT_RENDER_COUNT;
    },
    numberOfHiddenReviewers() {
      return this.users.length - DEFAULT_RENDER_COUNT;
    },
    uncollapsedUsers() {
      const uncollapsedLength = this.showLess
        ? Math.min(this.users.length, DEFAULT_RENDER_COUNT)
        : this.users.length;
      return this.showLess ? this.users.slice(0, uncollapsedLength) : this.users;
    },
    username() {
      return `@${this.firstUser.user.username}`;
    },
  },
  methods: {
    toggleShowLess() {
      this.showLess = !this.showLess;
    },
  },
};
</script>

<template>
  <div v-if="hasOneUser">
    <reviewer-avatar-link
      #default="{ reviewer }"
      tooltip-placement="left"
      :tooltip-has-name="false"
      :reviewer="firstUser"
      :root-path="rootPath"
      :issuable-type="issuableType"
    >
      <div class="gl-ml-3 gl-line-height-normal">
        <div class="author">{{ reviewer.user.name }}</div>
        <div class="username">{{ username }}</div>
      </div>
    </reviewer-avatar-link>
    <gl-button
      v-if="firstUser.reviewed"
      class="float-right"
      icon="clear-all"
      @click="$emit('request-review', firstUser.user.id)"
    />
  </div>
  <div v-else>
    <div class="user-list">
      <div v-for="reviewer in uncollapsedUsers" :key="reviewer.user.id" class="user-item">
        <reviewer-avatar-link
          :user="reviewer.user"
          :can-merge="reviewer.can_merge"
          :root-path="rootPath"
          :issuable-type="issuableType"
        />
      </div>
    </div>
    <div v-if="renderShowMoreSection" class="user-list-more">
      <button
        type="button"
        class="btn-link"
        data-qa-selector="more_reviewers_link"
        @click="toggleShowLess"
      >
        <template v-if="showLess">
          {{ hiddenReviewersLabel }}
        </template>
        <template v-else>{{ __('- show less') }}</template>
      </button>
    </div>
  </div>
</template>
