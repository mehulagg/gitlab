<script>
import { GlModal, GlSprintf } from '@gitlab/ui';

import { __, s__, sprintf } from '~/locale';
import * as Sentry from '~/sentry/wrapper';
import { DELETE_MODAL_ID } from '../constants';
import deleteComplianceFrameworkMutation from '../graphql/mutations/delete_compliance_framework.mutation.graphql';

export default {
  components: {
    GlModal,
    GlSprintf,
  },
  props: {
    framework: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      primaryProps: {
        text: this.$options.i18n.primarryButton,
        attributes: [{ category: 'primary' }, { variant: 'danger' }],
      },
      cancelProps: {
        text: this.$options.i18n.cancelButton,
      },
    };
  },
  computed: {
    name() {
      return this.framework?.name || '';
    },
    title() {
      return sprintf(this.$options.i18n.title, { framework: this.name });
    },
  },
  methods: {
    async deleteFramework() {
      this.reportDeleting();

      try {
        const {
          data: { destroyComplianceFramework },
        } = await this.$apollo.mutate({
          mutation: deleteComplianceFrameworkMutation,
          variables: {
            input: {
              id: this.framework.id,
            },
          },
        });

        const [error] = destroyComplianceFramework.errors;

        if (error) {
          this.reportError(new Error(error));
        } else {
          this.reportSuccess();
        }
      } catch (error) {
        this.reportError(error);
      }
    },
    reportDeleting() {
      this.$emit('deleting');
    },
    reportError(error) {
      Sentry.captureException(error);
      this.$emit('error');
    },
    reportSuccess() {
      this.$emit('delete');
    },
    show() {
      this.$refs.modal.show();
    },
  },
  i18n: {
    title: s__('ComplianceFrameworks|Delete compliance framework %{framework}'),
    message: s__(
      'ComplianceFrameworks|You are about to permanently delete the compliance framework %{framework} from all projects which currently have it applied, which may remove other functionality. This cannot be undone.',
    ),
    primarryButton: s__('ComplianceFrameworks|Delete framework'),
    cancelButton: __('Cancel'),
  },
  modalId: DELETE_MODAL_ID,
};
</script>
<template>
  <gl-modal
    ref="modal"
    :title="title"
    :modal-id="$options.modalId"
    :action-primary="primaryProps"
    :action-cancel="cancelProps"
    @primary="deleteFramework"
  >
    <gl-sprintf :message="$options.i18n.message">
      <template #framework>
        <strong>{{ name }}</strong>
      </template>
    </gl-sprintf>
  </gl-modal>
</template>
