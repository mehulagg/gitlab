<script>
import * as Sentry from '@sentry/browser';
import { isEqual } from 'lodash';
import { GlAlert, GlButton, GlForm, GlFormGroup, GlFormInput, GlModal } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { isAbsolute, redirectTo } from '~/lib/utils/url_utility';
import dastSiteProfileCreateMutation from '../graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from '../graphql/dast_site_profile_update.mutation.graphql';

const initField = value => ({
  value,
  state: null,
  feedback: null,
});

const extractFormValues = form =>
  Object.fromEntries(Object.entries(form).map(([key, { value }]) => [key, value]));

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
      profileName: initField(name),
      targetUrl: initField(targetUrl),
    };
    return {
      form,
      initialFormValues: extractFormValues(form),
      loading: false,
      showAlert: false,
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
      return !isEqual(extractFormValues(this.form), this.initialFormValues);
    },
    formHasErrors() {
      return Object.values(this.form).some(({ state }) => state === false);
    },
    someFieldEmpty() {
      return Object.values(this.form).some(({ value }) => !value);
    },
    isSubmitDisabled() {
      return this.formHasErrors || this.someFieldEmpty;
    },
  },
  methods: {
    validateTargetUrl() {
      if (!isAbsolute(this.form.targetUrl.value)) {
        this.form.targetUrl.state = false;
        this.form.targetUrl.feedback = s__(
          'DastProfiles|Please enter a valid URL format, ex: http://www.example.com/home',
        );
        return;
      }
      this.form.targetUrl.state = true;
      this.form.targetUrl.feedback = null;
    },
    onSubmit() {
      this.loading = true;
      this.hideErrors();

      const variables = {
        fullPath: this.fullPath,
        ...(this.isEdit ? { id: this.siteProfile.id } : {}),
        ...extractFormValues(this.form),
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
              this.showErrors(errors);
              this.loading = false;
            } else {
              redirectTo(this.profilesLibraryPath);
            }
          },
        )
        .catch(e => {
          Sentry.captureException(e);
          this.showErrors();
          this.loading = false;
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
    showErrors(errors = []) {
      this.errors = errors;
      this.showAlert = true;
    },
    hideErrors() {
      this.errors = [];
      this.showAlert = false;
    },
  },

  modalId: 'deleteDastProfileModal',
  emits: [],
};
</script>

<template>
  <gl-form @submit.prevent="onSubmit">
    <h2 class="gl-mb-6">
      {{ i18n.title }}
    </h2>

    <gl-alert v-if="showAlert" variant="danger" class="gl-mb-5" @dismiss="hideErrors">
      {{ i18n.errorMessage }}
      <ul v-if="errors.length" class="gl-mt-3 gl-mb-0">
        <li v-for="error in errors" :key="error" v-text="error"></li>
      </ul>
    </gl-alert>

    <gl-form-group :label="s__('DastProfiles|Profile name')">
      <gl-form-input
        v-model="form.profileName.value"
        class="mw-460"
        data-testid="profile-name-input"
        type="text"
      />
    </gl-form-group>

    <hr />

    <gl-form-group
      :invalid-feedback="form.targetUrl.feedback"
      :label="s__('DastProfiles|Target URL')"
    >
      <gl-form-input
        v-model="form.targetUrl.value"
        class="mw-460"
        data-testid="target-url-input"
        type="url"
        :state="form.targetUrl.state"
        @input="validateTargetUrl"
      />
    </gl-form-group>

    <hr />

    <div class="gl-mt-6 gl-pt-6">
      <gl-button
        type="submit"
        variant="success"
        class="js-no-auto-disable"
        data-testid="dast-site-profile-form-submit-button"
        :disabled="isSubmitDisabled"
        :loading="loading"
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
