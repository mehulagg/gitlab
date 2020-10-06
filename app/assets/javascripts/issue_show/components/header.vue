<script>
import {
  GlButton,
  GlDropdown,
  GlDropdownDivider,
  GlDropdownItem,
  GlIcon,
  GlLink,
} from '@gitlab/ui';
import { mapGetters, mapState } from 'vuex';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlDropdownDivider,
    GlDropdownItem,
    GlIcon,
    GlLink,
  },
  props: {
    canCreateIssue: {
      type: Boolean,
      required: true,
    },
    canReopenIssue: {
      type: Boolean,
      required: true,
    },
    canReportSpam: {
      type: Boolean,
      required: true,
    },
    canUpdateIssue: {
      type: Boolean,
      required: true,
    },
    isIssueAuthor: {
      type: Boolean,
      required: true,
    },
    closeIssuePath: {
      type: String,
      required: true,
    },
    newIssuePath: {
      type: String,
      required: true,
    },
    reopenIssuePath: {
      type: String,
      required: true,
    },
    reportAbusePath: {
      type: String,
      required: true,
    },
    submitAsSpamPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['getNoteableData']),
    isClosed() {
      return this.getNoteableData.state === 'closed';
    },
    buttonText() {
      return this.isClosed ? 'Reopen issue' : 'Close issue';
    },
    buttonVariant() {
      return this.isClosed ? 'default' : 'warning';
    },
  },
};
</script>

<template>
  <div class="detail-page-header-actions js-issuable-buttons">
    <gl-dropdown class="d-md-none d-lg-none d-xl-none" right text="Options">
      <gl-dropdown-item v-if="!isIssueAuthor" :href="reportAbusePath">
        Report abuse
      </gl-dropdown-item>
      <gl-dropdown-item v-if="canUpdateIssue" :href="closeIssuePath">Close issue</gl-dropdown-item>
      <gl-dropdown-item v-if="canReopenIssue" :href="reopenIssuePath">
        Reopen issue
      </gl-dropdown-item>
      <gl-dropdown-item v-if="canReportSpam" :href="submitAsSpamPath">
        Submit as spam
      </gl-dropdown-item>
      <gl-dropdown-item v-if="canCreateIssue" :href="newIssuePath">New issue</gl-dropdown-item>
    </gl-dropdown>

    <gl-button category="secondary" :variant="buttonVariant">{{ buttonText }}</gl-button>

    <gl-dropdown toggle-class="gl-border-0! gl-shadow-none!" class="" right no-caret>
      <template #button-content>
        <gl-icon name="ellipsis_v" />
        <span class="gl-sr-only">{{ __('Actions') }}</span>
      </template>

      <gl-dropdown-item>Promote to epic</gl-dropdown-item>
      <gl-dropdown-divider />
      <gl-dropdown-item v-if="canCreateIssue" :href="newIssuePath">New issue</gl-dropdown-item>
      <gl-dropdown-divider />
      <gl-dropdown-item v-if="!isIssueAuthor" :href="reportAbusePath">
        Report abuse
      </gl-dropdown-item>
      <gl-dropdown-divider />
      <gl-dropdown-item v-if="canReportSpam" :href="submitAsSpamPath">
        Submit as spam
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
