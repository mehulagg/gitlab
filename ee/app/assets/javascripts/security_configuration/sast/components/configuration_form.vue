<script>
import { GlAlert, GlButton } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { cloneDeep } from 'lodash';
import { __, s__ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import { redirectTo } from '~/lib/utils/url_utility';
import DynamicFields from './dynamic_fields.vue';
import { isValidConfigurationEntity } from './utils';

export default {
  components: {
    DynamicFields,
    GlAlert,
    GlButton,
  },
  inject: {
    createSastMergeRequestPath: {
      from: 'createSastMergeRequestPath',
      default: '',
    },
    securityConfigurationPath: {
      from: 'securityConfigurationPath',
      default: '',
    },
  },
  props: {
    entities: {
      type: Array,
      required: true,
      validator: value => value.every(isValidConfigurationEntity),
    },
  },
  data() {
    return {
      formEntities: cloneDeep(this.entities),
      hasSubmissionError: false,
      isSubmitting: false,
    };
  },
  methods: {
    onSubmit() {
      this.isSubmitting = true;
      this.hasSubmissionError = false;

      return axios
        .post(this.createSastMergeRequestPath, this.getFormData())
        .then(({ data }) => {
          const { filePath } = data;
          if (!filePath) {
            // eslint-disable-next-line @gitlab/require-i18n-strings
            throw new Error('SAST merge request creation failed');
          }

          redirectTo(filePath);
        })
        .catch(error => {
          this.isSubmitting = false;
          this.hasSubmissionError = true;
          Sentry.captureException(error);
        });
    },
    getFormData() {
      return this.formEntities.reduce((acc, { field, value }) => {
        acc[field] = value;
        return acc;
      }, {});
    },
  },
  i18n: {
    submissionError: s__(
      'SecurityConfiguration|An error occurred while creating the merge request.',
    ),
    submitButton: s__('SecurityConfiguration|Create Merge Request'),
    cancelButton: __('Cancel'),
  },

  emits: [],
};
</script>

<template>
  <form @submit.prevent="onSubmit">
    <dynamic-fields v-model="formEntities" />

    <hr />

    <gl-alert v-if="hasSubmissionError" class="gl-mb-5" variant="danger" :dismissible="false">{{
      $options.i18n.submissionError
    }}</gl-alert>

    <div class="gl-display-flex">
      <gl-button
        ref="submitButton"
        class="gl-mr-3 js-no-auto-disable"
        :loading="isSubmitting"
        type="submit"
        variant="success"
        category="primary"
        >{{ $options.i18n.submitButton }}</gl-button
      >

      <gl-button ref="cancelButton" :href="securityConfigurationPath">{{
        $options.i18n.cancelButton
      }}</gl-button>
    </div>
  </form>
</template>
