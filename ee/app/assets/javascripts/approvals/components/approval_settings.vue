<script>
import { mapActions, mapState } from 'vuex';
import { GlButton, GlForm, GlFormGroup, GlFormCheckbox, GlIcon, GlLink } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import { __ } from '~/locale';

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
      preventAuthorApproval: (state) => state.approvals.preventAuthorApproval,
      isLoading: (state) => state.approvals.isLoading,
    }),
  },
  created() {
    this.fetchSettings(this.approvalSettingsPath);
  },
  methods: {
    ...mapActions(['fetchSettings', 'updatePreventAuthorApproval']),
  },
  links: {
    preventAuthorApprovalDocsPath: helpPagePath(
      'user/project/merge_requests/merge_request_approvals',
      {
        anchor: 'allowing-merge-request-authors-to-approve-their-own-merge-requests',
      },
    ),
  },
  i18n: {
    authorApprovalLabel: __('Prevent MR approvals by the author.'),
    saveChanges: __('Save changes'),
    helpLabel: __('Help'),
  },
};
</script>

<template>
  <gl-form>
    <gl-form-group>
      <gl-form-checkbox
        :checked="preventAuthorApproval"
        data-testid="prevent-author-approval"
        @input="updatePreventAuthorApproval"
      >
        {{ $options.i18n.authorApprovalLabel }}
        <gl-link :href="$options.links.preventAuthorApprovalDocsPath" target="_blank">
          <gl-icon name="question-o" :aria-label="$options.i18n.helpLabel" :size="16"
        /></gl-link>
      </gl-form-checkbox>
    </gl-form-group>
    <gl-button type="submit" variant="success" category="primary" :disabled="isLoading">
      {{ $options.i18n.saveChanges }}
    </gl-button>
  </gl-form>
</template>
