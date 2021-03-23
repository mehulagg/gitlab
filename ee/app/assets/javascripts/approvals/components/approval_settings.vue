<script>
import { GlButton, GlForm, GlFormGroup, GlFormCheckbox, GlIcon, GlLink } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { helpPagePath } from '~/helpers/help_page_helper';
import { __ } from '~/locale';
import { APPROVALS_HELP_PATH } from '../constants';

const getHelpPagePath = (anchor) => helpPagePath(APPROVALS_HELP_PATH, { anchor });

export default {
  components: {
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormCheckbox,
    GlIcon,
    GlLink,
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
    preventAuthorApprovalDocsPath: getHelpPagePath(
      'allowing-merge-request-authors-to-approve-their-own-merge-requests',
    ),
    requireUserPasswordDocsPath: getHelpPagePath(
      'require-authentication-when-approving-a-merge-request',
    ),
  },
  i18n: {
    authorApprovalLabel: __('Prevent MR approvals by the author.'),
    requireUserPasswordLabel: __('Require user password for approvals.'),
    saveChanges: __('Save changes'),
    helpLabel: __('Help'),
  },
};
</script>

<template>
  <gl-form @submit.prevent="onSubmit">
    <gl-form-group>
      <gl-form-checkbox
        v-model="settings.preventAuthorApproval"
        data-testid="prevent-author-approval"
      >
        {{ $options.i18n.authorApprovalLabel }}
        <gl-link :href="$options.links.preventAuthorApprovalDocsPath" target="_blank">
          <gl-icon name="question-o" :aria-label="$options.i18n.helpLabel" :size="16"
        /></gl-link>
      </gl-form-checkbox>
      <gl-form-checkbox v-model="settings.requireUserPassword" data-testid="require-user-password">
        {{ $options.i18n.requireUserPasswordLabel }}
        <gl-link :href="$options.links.requireUserPasswordDocsPath" target="_blank">
          <gl-icon name="question-o" :aria-label="$options.i18n.helpLabel" :size="16"
        /></gl-link>
      </gl-form-checkbox>
    </gl-form-group>
    <gl-button type="submit" variant="success" category="primary" :disabled="isLoading">
      {{ $options.i18n.saveChanges }}
    </gl-button>
  </gl-form>
</template>
