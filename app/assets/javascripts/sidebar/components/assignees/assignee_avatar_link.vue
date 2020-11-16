<script>
import { GlTooltipDirective, GlLink } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import { isUserBusy } from '~/set_status_modal/utils';
import AssigneeAvatar from './assignee_avatar.vue';

export default {
  components: {
    AssigneeAvatar,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    user: {
      type: Object,
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
      return this.issuableType === 'merge_request' && !this.user.can_merge;
    },
    tooltipTitle() {
      const { status } = this.user;
      const isBusy = status?.availability && isUserBusy(status.availability);
      const userName = [this.user.name, isBusy ? __('(Busy)') : ''].join(' ');

      if (this.cannotMerge && this.tooltipHasName) {
        return sprintf(__('%{userName} (cannot merge)'), {
          userName,
        });
      } else if (this.cannotMerge) {
        return __('Cannot merge');
      } else if (this.tooltipHasName) {
        return userName;
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
    assigneeUrl() {
      return this.user.web_url || this.user.webUrl;
    },
  },
};
</script>

<template>
  <!-- must be `d-inline-block` or parent flex-basis causes width issues -->
  <gl-link
    v-gl-tooltip="tooltipOption"
    :href="assigneeUrl"
    :title="tooltipTitle"
    class="d-inline-block"
  >
    <!-- use d-flex so that slot can be appropriately styled -->
    <span class="d-flex">
      <assignee-avatar :user="user" :img-size="32" :issuable-type="issuableType" />
      <slot></slot>
    </span>
  </gl-link>
</template>
