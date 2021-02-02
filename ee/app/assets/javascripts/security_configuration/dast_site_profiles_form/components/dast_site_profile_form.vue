<script>
import { isEqual } from 'lodash';
import {
  GlAlert,
  GlButton,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlModal,
  GlFormTextarea,
} from '@gitlab/ui';
import { initFormField } from 'ee/security_configuration/utils';
import { returnToPreviousPageFactory } from 'ee/security_configuration/dast_profiles/redirect';
import * as Sentry from '~/sentry/wrapper';
import { __, s__ } from '~/locale';
import { serializeFormObject } from '~/lib/utils/forms';
import validation from '~/vue_shared/directives/validation';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import dastSiteProfileCreateMutation from '../graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from '../graphql/dast_site_profile_update.mutation.graphql';
import DastSiteAuthSection from './dast_site_auth_section.vue';

export default {
  name: 'DastSiteProfileForm',
  components: {
    GlAlert,
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlModal,
    GlFormTextarea,
    DastSiteAuthSection,
  },
  directives: {
    validation: validation(),
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    profilesLibraryPath: {
      type: String,
      required: true,
    },
    onDemandScansPath: {
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
    const { name = '', targetUrl = '', excludedUrls = '', requestHeaders = '' } =
      this.siteProfile || {};

    const form = {
      state: false,
      showValidation: false,
      fields: {
        profileName: initFormField({ value: name }),
        targetUrl: initFormField({ value: targetUrl }),
        excludedUrls: initFormField({ value: excludedUrls, required: false, skipValidation: true }),
        requestHeaders: initFormField({
          value: requestHeaders,
          required: false,
          skipValidation: true,
        }),
      },
    };

    return {
      form,
      authSection: {},
      initialFormValues: serializeFormObject(form.fields),
      isLoading: false,
      hasAlert: false,
      tokenId: null,
      token: null,
      errorMessage: '',
      errors: [],
      returnToPreviousPage: returnToPreviousPageFactory({
        onDemandScansPath: this.onDemandScansPath,
        profilesLibraryPath: this.profilesLibraryPath,
        urlParamKey: 'site_profile_id',
      }),
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
      const isAuthEnabled =
        this.glFeatures.securityDastSiteProfilesAdditionalFields &&
        this.authSection.fields.authEnabled.value;

      this.form.showValidation = true;

      if (!this.form.state || (isAuthEnabled && !this.authSection.state)) {
        return;
      }

      this.isLoading = true;
      this.hideErrors();
      const { errorMessage } = this.i18n;

      const variables = {
        input: {
          fullPath: this.fullPath,
          ...(this.isEdit ? { id: this.siteProfile.id } : {}),
          ...serializeFormObject(this.form.fields),
          ...(isAuthEnabled ? serializeFormObject(this.authSection.fields) : {}),
        },
      };

      this.$apollo
        .mutate({
          mutation: this.isEdit ? dastSiteProfileUpdateMutation : dastSiteProfileCreateMutation,
          variables,
        })
        .then(
          ({
            data: {
              [this.isEdit ? 'dastSiteProfileUpdate' : 'dastSiteProfileCreate']: {
                id,
                errors = [],
              },
            },
          }) => {
            if (errors.length > 0) {
              this.showErrors({ message: errorMessage, errors });
              this.isLoading = false;
            } else {
              this.returnToPreviousPage(id);
            }
          },
        )
        .catch((exception) => {
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
      this.returnToPreviousPage();
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

    <hr class="gl-border-gray-100" />

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

    <div v-if="glFeatures.securityDastSiteProfilesAdditionalFields" class="row">
      <gl-form-group
        :label="s__('DastProfiles|Excluded URLs (Optional)')"
        :invalid-feedback="form.fields.excludedUrls.feedback"
        class="col-md-6"
      >
        <gl-form-textarea
          v-model="form.fields.excludedUrls.value"
          data-testid="excluded-urls-input"
        />
      </gl-form-group>

      <gl-form-group
        :label="s__('DastProfiles|Additional request headers (Optional)')"
        :invalid-feedback="form.fields.requestHeaders.feedback"
        class="col-md-6"
      >
        <gl-form-textarea
          v-model="form.fields.requestHeaders.value"
          data-testid="request-headers-input"
        />
      </gl-form-group>
    </div>

    <dast-site-auth-section
      v-if="glFeatures.securityDastSiteProfilesAdditionalFields"
      v-model="authSection"
      :show-validation="form.showValidation"
    />

    <hr class="gl-border-gray-100" />

    <gl-button
      type="submit"
      variant="success"
      class="js-no-auto-disable"
      data-testid="dast-site-profile-form-submit-button"
      :loading="isLoading"
    >
      {{ s__('DastProfiles|Save profile') }}
    </gl-button>
    <gl-button
      class="gl-ml-2"
      data-testid="dast-site-profile-form-cancel-button"
      @click="onCancelClicked"
    >
      {{ __('Cancel') }}
    </gl-button>

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
