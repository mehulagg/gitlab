<script>
import { GlButton, GlModal } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import * as Sentry from '~/sentry/wrapper';
import { DAST_SITE_VALIDATION_REVOKE_MODAL_ID } from '../constants';
import dastSiteValidationRevokeMutation from '../graphql/dast_site_validation_revoke.mutation.graphql';

export default {
  name: 'DastSiteValidationModal',
  DAST_SITE_VALIDATION_MODAL_ID,
  components: {
    GlAlert,
    GlButton,
    GlModal,
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    targetUrl: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isCreatingToken: false,
      hasErrors: false,
      token: null,
      tokenId: null,
      validationMethod: DAST_SITE_VALIDATION_METHOD_TEXT_FILE,
      validationPath: '',
    };
  },
  computed: {
    modalProps() {
      return {
        id: DAST_SITE_VALIDATION_REVOKE_MODAL_ID,
        title: s__('DastSiteValidation|Revoke validation'),
        primaryProps: {
          text: s__('DastSiteValidation|Revoke validation'),
          attributes: [
            { disabled: this.hasErrors },
            { variant: 'success' },
            { category: 'primary' },
            { 'data-testid': 'revoke-validation-button' },
          ],
        },
        cancelProps: {
          text: __('Cancel'),
        },
      };
    },
  },
  methods: {
    async revoke() {
      try {
        await this.$apollo.mutate({
          mutation: dastSiteValidationRevokeMutation,
          variables: {
            fullPath: this.fullPath,
            normalizedTargetUrl: this.normalizedTargetUrl,
          },
        });
      } catch (exception) {
        this.onError(exception);
      }
    },
    onError(exception = null) {
      if (exception !== null) {
        Sentry.captureException(exception);
      }
      this.hasErrors = true;
    },
  },
};
</script>
<template>
  <gl-modal
    ref="modal"
    :modal-id="modalProps.id"
    :title="modalProps.title"
    :action-primary="modalProps.primaryProps"
    :action-cancel="modalProps.cancelProps"
    v-bind="$attrs"
    v-on="$listeners"
    @primary="validate"
  ></gl-modal>
</template>
