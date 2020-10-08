<script>
import { GlButton, GlDeprecatedButton, GlLoadingIcon, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import UserAvatarList from '~/vue_shared/components/user_avatar/user_avatar_list.vue';
import ApprovalsList from './approvals_list.vue';

export default {
  components: {
    GlIcon,
    GlButton,
    GlDeprecatedButton,
    GlLoadingIcon,
    UserAvatarList,
    ApprovalsList,
  },
  props: {
    suggestedApprovers: {
      type: Array,
      required: true,
    },
    approvalRules: {
      type: Array,
      required: true,
    },
    value: {
      type: Boolean,
      required: false,
      default: true,
    },
    isLoadingRules: {
      type: Boolean,
      required: false,
      default: false,
    },
    securityApprovalsHelpPagePath: {
      type: String,
      required: false,
      default: '',
    },
    eligibleApproversDocsPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    isCollapsed() {
      return !this.value;
    },
    ariaLabel() {
      return this.isCollapsed ? __('Expand approvers') : __('Collapse approvers');
    },
    angleIcon() {
      return this.isCollapsed ? 'chevron-right' : 'chevron-down';
    },
    suggestedApproversTrimmed() {
      return this.suggestedApprovers.slice(0, Math.min(5, this.suggestedApprovers.length));
    },
  },
  methods: {
    toggle() {
      this.$emit('input', !this.value);
    },
  },
};
</script>

<template>
  <div>
    <div class="mr-widget-extension d-flex align-items-center pl-3">
       <gl-button
        class="gl-mr-3"
        :aria-label="ariaLabel"
        :loading="!isCollapsed && isLoadingRules"
        :icon="angleIcon"
        category="tertiary"
        @click="toggle"
      />
      <template v-if="isCollapsed">
        <user-avatar-list :items="suggestedApproversTrimmed" :breakpoint="0" empty-text="" />
        <gl-deprecated-button variant="link" @click="toggle">{{
          __('View eligible approvers')
        }}</gl-deprecated-button>
      </template>
      <template v-else>
        <gl-deprecated-button variant="link" @click="toggle">{{
          __('Collapse')
        }}</gl-deprecated-button>
      </template>
    </div>
    <div v-if="!isCollapsed && approvalRules.length" class="border-top">
      <approvals-list
        :approval-rules="approvalRules"
        :security-approvals-help-page-path="securityApprovalsHelpPagePath"
        :eligible-approvers-docs-path="eligibleApproversDocsPath"
      />
    </div>
  </div>
</template>
