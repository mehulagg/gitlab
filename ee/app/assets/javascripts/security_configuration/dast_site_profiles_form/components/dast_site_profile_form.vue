<script>
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
import * as Sentry from '~/sentry/wrapper';
import { __, s__ } from '~/locale';
import { redirectTo } from '~/lib/utils/url_utility';
import { serializeFormObject } from '~/lib/utils/forms';
import { fetchPolicies } from '~/lib/graphql';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import validation from '~/vue_shared/directives/validation';
import DastSiteValidation from './dast_site_validation.vue';
import dastSiteProfileCreateMutation from '../graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from '../graphql/dast_site_profile_update.mutation.graphql';
import dastSiteTokenCreateMutation from '../graphql/dast_site_token_create.mutation.graphql';
import dastSiteValidationQuery from '../graphql/dast_site_validation.query.graphql';
import { DAST_SITE_VALIDATION_STATUS, DAST_SITE_VALIDATION_POLL_INTERVAL } from '../constants';

const { PENDING, INPROGRESS, PASSED, FAILED } = DAST_SITE_VALIDATION_STATUS;

const initField = value => ({
  value,
  state: null,
  feedback: null,
});

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
        profileName: initField(name),
        targetUrl: initField(targetUrl),
      },
    };

    return {
      fetchValidationTimeout: null,
      form,
      initialFormValues: serializeFormObject(form.fields),
      isFetchingValidationStatus: false,
      isValidatingSite: false,
      isLoading: false,
      hasAlert: false,
      tokenId: null,
      token: null,
      isSiteValidationActive: false,
      isSiteValidationTouched: false,
      validationStatus: null,
      errorMessage: '',
      errors: [],
    };
  },
  computed: {
    isEdit() {
      return Boolean(this.siteProfile?.id);
    },
    isSiteValidationDisabled() {
      return !this.form.fields.targetUrl.state || this.validationStatusMatches(INPROGRESS);
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
      return !isEqual(serializeFormObject(this.form.fields), this.initialFormValues);
    },
    isSubmitDisabled() {
      return (
        this.validationStatusMatches(INPROGRESS) ||
        (this.isSiteValidationActive && !this.validationStatusMatches(PASSED))
      );
    },
    showValidationSection() {
      return (
        this.isSiteValidationActive &&
        !this.isValidatingSite &&
        ![INPROGRESS, PASSED].some(this.validationStatusMatches)
      );
    },
    siteValidationStatusDescription() {
      const descriptions = {
        [PENDING]: { text: s__('DastProfiles|Site must be validated to run an active scan.') },
        [INPROGRESS]: {
          text: s__('DastProfiles|Validation is in progress...'),
        },
        [PASSED]: {
          text: s__(
            'DastProfiles|Validation succeeded. Both active and passive scans can be run against the target site.',
          ),
          cssClass: 'gl-text-green-500',
        },
        [FAILED]: {
          text: s__('DastProfiles|Validation failed. Please try again.'),
          cssClass: 'gl-text-red-500',
          dismissed: this.isSiteValidationTouched,
        },
      };

      const defaultDescription = descriptions[PENDING];
      const currentStatusDescription = descriptions[this.validationStatus];

      return currentStatusDescription && !currentStatusDescription.dismissed
        ? currentStatusDescription
        : defaultDescription;
    },
  },
  async mounted() {
    if (this.isEdit) {
      this.form.showValidation = true;

      if (this.glFeatures.securityOnDemandScansSiteValidation) {
        await this.fetchValidationStatus();

        this.isSiteValidationActive = this.validationStatusMatches(PASSED);
      }
    }
  },
  destroyed() {
    clearTimeout(this.fetchValidationTimeout);
    this.fetchValidationTimeout = null;
  },
  methods: {
    async validateSite(validate) {
      this.isSiteValidationActive = validate;
      this.isSiteValidationTouched = true;
      this.tokenId = null;
      this.token = null;

      if (!validate) {
        this.validationStatus = null;
      } else {
        try {
          this.isValidatingSite = true;

          await this.fetchValidationStatus();

          if (![PASSED, INPROGRESS].some(this.validationStatusMatches)) {
            await this.createValidationToken();
          }
        } catch (exception) {
          this.captureException(exception);
          this.isSiteValidationActive = false;
        } finally {
          this.isValidatingSite = false;
        }
      }
    },
    validationStatusMatches(status) {
      return this.validationStatus === status;
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
            targetUrl: this.form.fields.targetUrl.value,
          },
          fetchPolicy: fetchPolicies.NETWORK_ONLY,
        });
        this.validationStatus = status;

        if (this.validationStatusMatches(INPROGRESS)) {
          await new Promise(resolve => {
            this.fetchValidationTimeout = setTimeout(resolve, DAST_SITE_VALIDATION_POLL_INTERVAL);
          });
          await this.fetchValidationStatus();
        }
      } catch (exception) {
        this.showErrors({
          message: this.i18n.siteValidation.validationStatusFetchError,
        });
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
          variables: {
            projectFullPath: this.fullPath,
            targetUrl: this.form.fields.targetUrl.value,
          },
        });
        if (errors.length) {
          this.showErrors({ message: errorMessage, errors });
        } else {
          this.tokenId = id;
          this.token = token;
        }
      } catch (exception) {
        this.showErrors({ message: errorMessage });

        throw new Error(exception);
      }
    },
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
    onValidationSuccess() {
      this.validationStatus = PASSED;
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
      :description="
        isSiteValidationActive && !isValidatingSite
          ? s__('DastProfiles|Validation must be turned off to change the target URL')
          : null
      "
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
        :disabled="isSiteValidationActive"
      />
    </gl-form-group>

    <template v-if="glFeatures.securityOnDemandScansSiteValidation">
      <gl-form-group :label="s__('DastProfiles|Validate target site')">
        <template #description>
          <p
            v-if="siteValidationStatusDescription.text"
            class="gl-mt-3"
            :class="siteValidationStatusDescription.cssClass"
            data-testid="siteValidationStatusDescription"
          >
            {{ siteValidationStatusDescription.text }}
          </p>
        </template>
        <gl-toggle
          data-testid="dast-site-validation-toggle"
          :value="isSiteValidationActive"
          :disabled="isSiteValidationDisabled"
          :is-loading="
            !isSiteValidationDisabled && (isFetchingValidationStatus || isValidatingSite)
          "
          @change="validateSite"
        />
      </gl-form-group>

      <gl-collapse :visible="showValidationSection">
        <dast-site-validation
          :full-path="fullPath"
          :token-id="tokenId"
          :token="token"
          :target-url="form.fields.targetUrl.value"
          @success="onValidationSuccess"
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
