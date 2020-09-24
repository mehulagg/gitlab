<script>
import * as Sentry from '@sentry/browser';
import { isEqual } from 'lodash';
import {
  GlAlert,
  GlButton,
  GlCollapse,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlModal,
  GlToggle,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { isAbsolute, redirectTo } from '~/lib/utils/url_utility';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import DastSiteValidation from './dast_site_validation.vue';
import dastSiteProfileCreateMutation from '../graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from '../graphql/dast_site_profile_update.mutation.graphql';
import dastSiteTokenCreateMutation from '../graphql/dast_site_token_create.mutation.graphql';
import dastSiteValidationQuery from '../graphql/dast_site_validation.query.graphql';
import { DAST_SITE_VALIDATION_STATUS } from '../constants';

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
    GlCollapse,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlModal,
    GlToggle,
    DastSiteValidation,
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
    siteProfile: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    const { name = '', targetUrl = '' } = this.siteProfile || {};
    const isSiteValid = false;
    const form = {
      profileName: initField(name),
      targetUrl: initField(targetUrl),
    };
    return {
      form,
      initialFormValues: extractFormValues(form),
      isFetchingValidationStatus: false,
      isValidatingSite: false,
      loading: false,
      showAlert: false,
      tokenId: null,
      token: null,
      isSiteValid,
      validateSite: isSiteValid,
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
        siteValidation: {
          validationStatusFetchError: s__(
            'DastProfiles|Could not retrieve site validation status. Please refresh the page, or try again later.',
          ),
          createTokenError: s__(
            'DastProfiles|Could not create site validation token. Please refresh the page, or try again later.',
          ),
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
      return (this.validateSite && !this.isSiteValid) || this.formHasErrors || this.someFieldEmpty;
    },
    showValidationSection() {
      return this.validateSite && !this.isSiteValid && !this.isValidatingSite;
    },
  },
  watch: {
    async validateSite(validate) {
      this.tokenId = null;
      this.token = null;
      if (!validate) {
        this.isSiteValid = false;
      } else {
        try {
          this.isValidatingSite = true;
          await this.fetchValidationStatus();

          if (!this.isSiteValid) {
            await this.createValidationToken();
          }
        } catch (exception) {
          this.captureException(exception);
        } finally {
          this.isValidatingSite = false;
        }
      }
    },
  },
  async created() {
    if (this.isEdit) {
      this.validateTargetUrl();

      if (this.glFeatures.securityOnDemandScansSiteValidation) {
        await this.fetchValidationStatus();
      }
    }
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
    async fetchValidationStatus() {
      this.isFetchingValidationStatus = true;

      try {
        const {
          data: {
            project: {
              dastSiteValidation: { status },
            },
          },
        } = await this.$apollo.query({
          query: dastSiteValidationQuery,
          variables: {
            fullPath: this.fullPath,
            targetUrl: this.form.targetUrl.value,
          },
        });
        this.isSiteValid = status === DAST_SITE_VALIDATION_STATUS.VALID;
      } catch (exception) {
        this.showErrors({
          message: this.i18n.siteValidation.validationStatusFetchError,
        });
        this.validateSite = false;

        throw new Error(exception);
      } finally {
        this.isFetchingValidationStatus = false;
      }
    },
    async createValidationToken() {
      const errorMessage = this.i18n.siteValidation.createTokenError;

      try {
        const {
          data: {
            dastSiteTokenCreate: { id, token, errors = [] },
          },
        } = await this.$apollo.mutate({
          mutation: dastSiteTokenCreateMutation,
          variables: { projectFullPath: this.fullPath, targetUrl: this.form.targetUrl.value },
        });
        if (errors.length) {
          this.showErrors({ message: errorMessage, errors });
        } else {
          this.tokenId = id;
          this.token = token;
        }
      } catch (exception) {
        this.showErrors({ message: errorMessage });
        this.validateSite = false;

        throw new Error(exception);
      }
    },
    onSubmit() {
      this.loading = true;
      this.hideErrors();
      const { errorMessage } = this.i18n;

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
              this.showErrors({ message: errorMessage, errors });
              this.loading = false;
            } else {
              redirectTo(this.profilesLibraryPath);
            }
          },
        )
        .catch(exception => {
          this.showErrors({ message: errorMessage });
          this.captureException(exception);
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
    captureException(exception) {
      Sentry.captureException(exception);
    },
    showErrors({ message, errors = [] }) {
      this.errorMessage = message;
      this.errors = errors;
      this.showAlert = true;
    },
    hideErrors() {
      this.errorMessage = '';
      this.errors = [];
      this.showAlert = false;
    },
  },
  modalId: 'deleteDastProfileModal',
};
</script>

<template>
  <gl-form @submit.prevent="onSubmit">
    <h2 class="gl-mb-6">
      {{ i18n.title }}
    </h2>

    <gl-alert
      v-if="showAlert"
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
      data-testid="target-url-input-group"
      :invalid-feedback="form.targetUrl.feedback"
      :description="
        validateSite && !isValidatingSite
          ? s__('DastProfiles|Validation must be turned off to change the target URL')
          : null
      "
      :label="s__('DastProfiles|Target URL')"
    >
      <gl-form-input
        v-model="form.targetUrl.value"
        class="mw-460"
        data-testid="target-url-input"
        type="url"
        :state="form.targetUrl.state"
        :disabled="validateSite"
        @input="validateTargetUrl"
      />
    </gl-form-group>

    <template v-if="glFeatures.securityOnDemandScansSiteValidation">
      <gl-form-group :label="s__('DastProfiles|Validate target site')">
        <template #description>
          <p v-if="!isSiteValid" class="gl-mt-3">
            {{ s__('DastProfiles|Site must be validated to run an active scan.') }}
          </p>
          <p v-else class="gl-text-green-500 gl-mt-3">
            {{
              s__(
                'DastProfiles|Validation succeeded. Both active and passive scans can be run against the target site.',
              )
            }}
          </p>
        </template>
        <gl-toggle
          v-model="validateSite"
          data-testid="dast-site-validation-toggle"
          :disabled="!form.targetUrl.state"
          :is-loading="isFetchingValidationStatus || isValidatingSite"
        />
      </gl-form-group>

      <gl-collapse :visible="showValidationSection">
        <dast-site-validation
          :full-path="fullPath"
          :token-id="tokenId"
          :token="token"
          :target-url="form.targetUrl.value"
          @success="isSiteValid = true"
        />
      </gl-collapse>
    </template>

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
