<script>
// NOTE! For the first iteration, we are simply copying the implementation of Assignees
// It will soon be overhauled in Issue https://gitlab.com/gitlab-org/gitlab/-/issues/233736
import { GlTooltipDirective, GlLink } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import ReviewerAvatar from './reviewer_avatar.vue';

export default {
  components: {
    ReviewerAvatar,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    reviewer: {
      type: Object,
      required: true,
    },
    rootPath: {
      type: String,
      required: true,
    },
    tooltipPlacement: {
      type: String,
      default: 'bottom',
      required: false,
    },
    tooltipHasName: {
      type: Boolean,
      default: true,
      required: false,
    },
    issuableType: {
      type: String,
      default: 'issue',
      required: false,
    },
  },
  computed: {
    cannotMerge() {
      return this.issuableType === 'merge_request' && !this.reviewer.user.can_merge;
    },
    tooltipTitle() {
      if (this.cannotMerge && this.tooltipHasName) {
        return sprintf(__('%{userName} (cannot merge)'), { userName: this.reviewer.user.name });
      } else if (this.cannotMerge) {
        return __('Cannot merge');
      } else if (this.tooltipHasName) {
        return this.reviewer.user.name;
      }

      return '';
    },
    tooltipOption() {
      return {
        container: 'body',
        placement: this.tooltipPlacement,
        boundary: 'viewport',
      };
    },
    reviewerUrl() {
      return this.reviewer.user.web_url;
    },
  },
};
</script>

<template>
  <!-- must be `d-inline-block` or parent flex-basis causes width issues -->
  <gl-link
    v-gl-tooltip="tooltipOption"
    :href="reviewerUrl"
    :title="tooltipTitle"
    class="d-inline-block"
  >
    <!-- use d-flex so that slot can be appropriately styled -->
    <span class="d-flex">
      <reviewer-avatar
        :user="reviewer.user"
        :can-merge="reviewer.can_merge"
        :img-size="32"
        :issuable-type="issuableType"
      />
      <slot :reviewer="reviewer"></slot>
    </span>
  </gl-link>
</template>
