<script>
import { GlButton, GlForm, GlFormGroup } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __ } from '~/locale';
import * as types from '../stores/modules/group_settings/mutation_types';
import ApprovalSettingsCheckbox from './approval_settings_checkbox.vue';

export default {
  components: {
    ApprovalSettingsCheckbox,
    GlButton,
    GlForm,
    GlFormGroup,
  },
  props: {
    approvalSettingsPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState({
      settings: (state) => state.approvals.settings,
      isLoading: (state) => state.approvals.isLoading,
    }),
    preventAuthorApproval: {
      get() {
        return this.settings.preventAuthorApproval;
      },
      set(value) {
        this.setSetting({ type: types.SET_SETTING_PREVENT_AUTHOR_APPROVAL, value });
      },
    },
    preventMrApprovalRuleEdit: {
      get() {
        return this.settings.preventMrApprovalRuleEdit;
      },
      set(value) {
        this.setSetting({ type: types.SET_SETTING_PREVENT_MR_APPROVAL_RULE_EDIT, value });
      },
    },
    requireUserPassword: {
      get() {
        return this.settings.requireUserPassword;
      },
      set(value) {
        this.setSetting({ type: types.SET_SETTING_REQUIRE_USER_PASSWORD, value });
      },
    },
    removeApprovalsOnPush: {
      get() {
        return this.settings.removeApprovalsOnPush;
      },
      set(value) {
        this.setSetting({ type: types.SET_SETTING_REMOVE_APPROVALS_ON_PUSH, value });
      },
    },
    preventCommittersApproval: {
      get() {
        return this.settings.preventCommittersApproval;
      },
      set(value) {
        this.setSetting({ type: types.SET_SETTING_PREVENT_COMMITTERS_APPROVAL, value });
      },
    },
  },
  created() {
    this.fetchSettings(this.approvalSettingsPath);
  },
  methods: {
    ...mapActions(['fetchSettings', 'updateSettings', 'setSetting']),
    onSubmit() {
      this.updateSettings(this.approvalSettingsPath);
    },
  },
  links: {
    preventAuthorApprovalDocsAnchor:
      'allowing-merge-request-authors-to-approve-their-own-merge-requests',
    preventMrApprovalRuleEditDocsAnchor: 'editing--overriding-approval-rules-per-merge-request',
    requireUserPasswordDocsAnchor: 'require-authentication-when-approving-a-merge-request',
    removeApprovalsOnPushDocsAnchor: 'resetting-approvals-on-push',
    preventCommittersApprovalAnchor: 'prevent-approval-of-merge-requests-by-their-committers',
  },
  i18n: {
    authorApprovalLabel: __('Prevent MR approvals by the author.'),
    preventMrApprovalRuleEditLabel: __('Prevent users from modifying MR approval rules.'),
    preventCommittersApprovalLabel: __(
      'Prevent approval of merge requests by merge request committers.',
    ),
    requireUserPasswordLabel: __('Require user password for approvals.'),
    removeApprovalsOnPushLabel: __(
      'Remove all approvals in a merge request when new commits are pushed to its source branch.',
    ),
    saveChanges: __('Save changes'),
  },
};
</script>

<template>
  <gl-form @submit.prevent="onSubmit">
    <gl-form-group>
      <approval-settings-checkbox
        v-model="preventAuthorApproval"
        :label="$options.i18n.authorApprovalLabel"
        :anchor="$options.links.preventAuthorApprovalDocsAnchor"
        data-testid="prevent-author-approval"
      />
      <approval-settings-checkbox
        v-model="preventMrApprovalRuleEdit"
        :label="$options.i18n.preventMrApprovalRuleEditLabel"
        :anchor="$options.links.preventMrApprovalRuleEditDocsAnchor"
        data-testid="prevent-mr-approval-rule-edit"
      />
      <approval-settings-checkbox
        v-model="requireUserPassword"
        :label="$options.i18n.requireUserPasswordLabel"
        :anchor="$options.links.requireUserPasswordDocsAnchor"
        data-testid="require-user-password"
      />
      <approval-settings-checkbox
        v-model="removeApprovalsOnPush"
        :label="$options.i18n.removeApprovalsOnPushLabel"
        :anchor="$options.links.removeApprovalsOnPushDocsAnchor"
        data-testid="remove-approvals-on-push"
      />
      <approval-settings-checkbox
        v-model="preventCommittersApproval"
        :label="$options.i18n.preventCommittersApprovalLabel"
        :anchor="$options.links.preventCommittersApprovalAnchor"
        data-testid="prevent-committers-approval"
      />
    </gl-form-group>
    <gl-button type="submit" variant="success" category="primary" :disabled="isLoading">
      {{ $options.i18n.saveChanges }}
    </gl-button>
  </gl-form>
</template>
