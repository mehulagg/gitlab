<script>
import { isEqual } from 'lodash';
import { GlAlert, GlButton, GlForm, GlFormGroup, GlFormInput, GlModal } from '@gitlab/ui';
import { initFormField } from 'ee/security_configuration/utils';
import * as Sentry from '~/sentry/wrapper';
import { __, s__ } from '~/locale';
import { redirectTo } from '~/lib/utils/url_utility';
import { serializeFormObject } from '~/lib/utils/forms';
import validation from '~/vue_shared/directives/validation';
import dastSiteProfileCreateMutation from '../graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from '../graphql/dast_site_profile_update.mutation.graphql';

export default {
  name: 'DastSiteProfileForm',
  components: {
    GlAlert,
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlModal,
  },
  directives: {
    validation: validation(),
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    profilesLibraryPath: {
      type: String,
      required: true,
    },
    siteProfile: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    const { name = '', targetUrl = '' } = this.siteProfile || {};

    const form = {
      state: false,
      showValidation: false,
      fields: {
        profileName: initFormField({ value: name }),
        targetUrl: initFormField({ value: targetUrl }),
      },
    };

    return {
      form,
      initialFormValues: serializeFormObject(form.fields),
      isLoading: false,
      hasAlert: false,
      tokenId: null,
      token: null,
      errorMessage: '',
      errors: [],
    };
  },
  computed: {
    isEdit() {
      return Boolean(this.siteProfile?.id);
    },
    i18n() {
      const { isEdit } = this;
      return {
        title: isEdit
          ? s__('DastProfiles|Edit site profile')
          : s__('DastProfiles|New site profile'),
        errorMessage: isEdit
          ? s__('DastProfiles|Could not update the site profile. Please try again.')
          : s__('DastProfiles|Could not create the site profile. Please try again.'),
        modal: {
          title: isEdit
            ? s__('DastProfiles|Do you want to discard your changes?')
            : s__('DastProfiles|Do you want to discard this site profile?'),
          okTitle: __('Discard'),
          cancelTitle: __('Cancel'),
        },
      };
    },
    formTouched() {
      return !isEqual(serializeFormObject(this.form.fields), this.initialFormValues);
    },
  },
  async mounted() {
    if (this.isEdit) {
      this.form.showValidation = true;
    }
  },
  methods: {
    onSubmit() {
      this.form.showValidation = true;

      if (!this.form.state) {
        return;
      }

      this.isLoading = true;
      this.hideErrors();
      const { errorMessage } = this.i18n;

      const variables = {
        fullPath: this.fullPath,
        ...(this.isEdit ? { id: this.siteProfile.id } : {}),
        ...serializeFormObject(this.form.fields),
      };

      this.$apollo
        .mutate({
          mutation: this.isEdit ? dastSiteProfileUpdateMutation : dastSiteProfileCreateMutation,
          variables,
        })
        .then(
          ({
            data: {
              [this.isEdit ? 'dastSiteProfileUpdate' : 'dastSiteProfileCreate']: { errors = [] },
            },
          }) => {
            if (errors.length > 0) {
              this.showErrors({ message: errorMessage, errors });
              this.isLoading = false;
            } else {
              redirectTo(this.profilesLibraryPath);
            }
          },
        )
        .catch(exception => {
          this.showErrors({ message: errorMessage });
          this.captureException(exception);
          this.isLoading = false;
        });
    },
    onCancelClicked() {
      if (!this.formTouched) {
        this.discard();
      } else {
        this.$refs[this.$options.modalId].show();
      }
    },
    discard() {
      redirectTo(this.profilesLibraryPath);
    },
    captureException(exception) {
      Sentry.captureException(exception);
    },
    showErrors({ message, errors = [] }) {
      this.errorMessage = message;
      this.errors = errors;
      this.hasAlert = true;
    },
    hideErrors() {
      this.errorMessage = '';
      this.errors = [];
      this.hasAlert = false;
    },
  },
  modalId: 'deleteDastProfileModal',
};
</script>

<template>
  <gl-form novalidate @submit.prevent="onSubmit">
    <h2 class="gl-mb-6">
      {{ i18n.title }}
    </h2>

    <gl-alert
      v-if="hasAlert"
      variant="danger"
      class="gl-mb-5"
      data-testid="dast-site-profile-form-alert"
      @dismiss="hideErrors"
    >
      {{ errorMessage }}
      <ul v-if="errors.length" class="gl-mt-3 gl-mb-0">
        <li v-for="error in errors" :key="error" v-text="error"></li>
      </ul>
    </gl-alert>

    <gl-form-group
      :label="s__('DastProfiles|Profile name')"
      :invalid-feedback="form.fields.profileName.feedback"
    >
      <gl-form-input
        v-model="form.fields.profileName.value"
        v-validation:[form.showValidation]
        name="profileName"
        class="mw-460"
        data-testid="profile-name-input"
        type="text"
        required
        :state="form.fields.profileName.state"
      />
    </gl-form-group>

    <hr />

    <gl-form-group
      data-testid="target-url-input-group"
      :invalid-feedback="form.fields.targetUrl.feedback"
      :label="s__('DastProfiles|Target URL')"
    >
      <gl-form-input
        v-model="form.fields.targetUrl.value"
        v-validation:[form.showValidation]
        name="targetUrl"
        class="mw-460"
        data-testid="target-url-input"
        required
        type="url"
        :state="form.fields.targetUrl.state"
      />
    </gl-form-group>

    <hr />

    <div class="gl-mt-6 gl-pt-6">
      <gl-button
        type="submit"
        variant="success"
        class="js-no-auto-disable"
        data-testid="dast-site-profile-form-submit-button"
        :loading="isLoading"
      >
        {{ s__('DastProfiles|Save profile') }}
      </gl-button>
      <gl-button data-testid="dast-site-profile-form-cancel-button" @click="onCancelClicked">
        {{ __('Cancel') }}
      </gl-button>
    </div>

    <gl-modal
      :ref="$options.modalId"
      :modal-id="$options.modalId"
      :title="i18n.modal.title"
      :ok-title="i18n.modal.okTitle"
      :cancel-title="i18n.modal.cancelTitle"
      ok-variant="danger"
      body-class="gl-display-none"
      data-testid="dast-site-profile-form-cancel-modal"
      @ok="discard()"
    />
  </gl-form>
</template>
