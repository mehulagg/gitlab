<script>
import { GlButton, GlForm, GlFormGroup } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __ } from '~/locale';
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
  },
  created() {
    this.fetchSettings(this.approvalSettingsPath);
  },
  methods: {
    ...mapActions(['fetchSettings', 'updateSettings']),
    onSubmit() {
      this.updateSettings(this.approvalSettingsPath);
    },
  },
  links: {
    preventAuthorApprovalDocsAnchor:
      'allowing-merge-request-authors-to-approve-their-own-merge-requests',
    requireUserPasswordDocsAnchor: 'require-authentication-when-approving-a-merge-request',
  },
  i18n: {
    authorApprovalLabel: __('Prevent MR approvals by the author.'),
    requireUserPasswordLabel: __('Require user password for approvals.'),
    saveChanges: __('Save changes'),
  },
};
</script>

<template>
  <gl-form @submit.prevent="onSubmit">
    <gl-form-group>
      <approval-settings-checkbox
        v-model="settings.preventAuthorApproval"
        :label="$options.i18n.authorApprovalLabel"
        :anchor="$options.links.preventAuthorApprovalDocsAnchor"
        data-testid="prevent-author-approval"
      />
      <approval-settings-checkbox
        v-model="settings.requireUserPassword"
        :label="$options.i18n.requireUserPasswordLabel"
        :anchor="$options.links.requireUserPasswordDocsAnchor"
        data-testid="require-user-password"
      />
    </gl-form-group>
    <gl-button type="submit" variant="success" category="primary" :disabled="isLoading">
      {{ $options.i18n.saveChanges }}
    </gl-button>
  </gl-form>
</template>
