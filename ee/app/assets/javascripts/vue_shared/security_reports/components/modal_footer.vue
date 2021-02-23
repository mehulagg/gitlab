<script>
import { GlButton, GlIcon } from '@gitlab/ui';
import DismissButton from 'ee/vue_shared/security_reports/components/dismiss_button.vue';
import SplitButton from 'ee/vue_shared/security_reports/components/split_button.vue';
import { s__ } from '~/locale';

export default {
  components: {
    DismissButton,
    GlButton,
    SplitButton,
    GlIcon,
  },
  props: {
    modal: {
      type: Object,
      required: true,
    },
    isDismissed: {
      type: Boolean,
      required: false,
      default: false,
    },
    canCreateIssue: {
      type: Boolean,
      required: false,
      default: false,
    },
    canCreateMergeRequest: {
      type: Boolean,
      required: false,
      default: false,
    },
    canDownloadPatch: {
      type: Boolean,
      required: false,
      default: false,
    },
    canDismissVulnerability: {
      type: Boolean,
      required: false,
      default: false,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    isCreatingIssue: {
      type: Boolean,
      required: true,
    },
    isDismissingVulnerability: {
      type: Boolean,
      required: true,
    },
    isCreatingMergeRequest: {
      type: Boolean,
      required: true,
    },
    vulnerability: {
      type: Object,
      required: true,
    },
  },
  computed: {
    createIssueButtonText() {
      return this.vulnerability.create_jira_issue_url
        ? s__('ciReport|Create Jira issue')
        : s__('ciReport|Create issue');
    },

    actionButtons() {
      const buttons = [];
      const issueButton = {
        name: this.createIssueButtonText,
        tagline: s__('ciReport|Investigate this vulnerability by creating an issue'),
        isLoading: this.isCreatingIssue,
        action: this.vulnerability.create_jira_issue_url ? undefined : 'createNewIssue',
        href: this.vulnerability.create_jira_issue_url,
        icon: this.vulnerability.create_jira_issue_url ? 'external-link' : undefined,
      };
      const MRButton = {
        name: s__('ciReport|Resolve with merge request'),
        tagline: s__('ciReport|Automatically apply the patch in a new branch'),
        isLoading: this.isCreatingMergeRequest,
        action: 'createMergeRequest',
      };
      const DownloadButton = {
        name: s__('ciReport|Download patch to resolve'),
        tagline: s__('ciReport|Download the patch to apply it manually'),
        action: 'downloadPatch',
      };

      if (this.canCreateMergeRequest) {
        buttons.push(MRButton);
      }

      if (this.canDownloadPatch) {
        buttons.push(DownloadButton);
      }

      if (this.canCreateIssue) {
        buttons.push(issueButton);
      }

      return buttons;
    },
  },
};
</script>

<template>
  <div>
    <gl-button :disabled="disabled" @click="$emit('cancel')">
      {{ __('Cancel') }}
    </gl-button>

    <dismiss-button
      v-if="canDismissVulnerability"
      :is-dismissing="isDismissingVulnerability"
      :is-dismissed="isDismissed"
      :disabled="disabled"
      @dismissVulnerability="$emit('dismissVulnerability')"
      @openDismissalCommentBox="$emit('openDismissalCommentBox')"
      @revertDismissVulnerability="$emit('revertDismissVulnerability')"
    />

    <split-button
      v-if="actionButtons.length > 1"
      :buttons="actionButtons"
      class="js-split-button"
      data-qa-selector="resolve_split_button"
      :disabled="disabled"
      @createMergeRequest="$emit('createMergeRequest')"
      @createNewIssue="$emit('createNewIssue')"
      @downloadPatch="$emit('downloadPatch')"
    />

    <gl-button
      v-else-if="actionButtons.length > 0"
      :loading="actionButtons[0].isLoading"
      :disabled="disabled"
      variant="success"
      category="secondary"
      data-testid="create-issue-button"
      data-qa-selector="create_issue_button"
      :target="actionButtons[0].href ? '_blank' : undefined"
      :href="actionButtons[0].href"
      @click="$emit(actionButtons[0].action)"
    >
      <gl-icon
        v-if="actionButtons[0].icon"
        :name="actionButtons[0].icon"
        class="gl-vertical-align-middle"
      />
      {{ __(actionButtons[0].name) }}
    </gl-button>
  </div>
</template>
