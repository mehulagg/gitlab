<script>
import {
  GlButton,
  GlFormGroup,
  GlFormInput,
  GlFormInputGroup,
  GlFormRadioGroup,
  GlIcon,
  GlInputGroupText,
  GlLoadingIcon,
  GlModal,
} from '@gitlab/ui';
import { omit } from 'lodash';
import * as Sentry from '~/sentry/wrapper';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import download from '~/lib/utils/downloader';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { cleanLeadingSeparator, joinPaths, stripPathTail } from '~/lib/utils/url_utility';
import {
  DAST_SITE_VALIDATION_HTTP_HEADER_KEY,
  DAST_SITE_VALIDATION_METHOD_HTTP_HEADER,
  DAST_SITE_VALIDATION_METHOD_TEXT_FILE,
  DAST_SITE_VALIDATION_METHODS,
  DAST_SITE_VALIDATION_STATUS,
} from '../constants';
import dastSiteTokenCreateMutation from '../graphql/dast_site_token_create.mutation.graphql';
import dastSiteValidationCreateMutation from '../graphql/dast_site_validation_create.mutation.graphql';

export default {
  name: 'DastSiteValidationModal',
  components: {
    ClipboardButton,
    GlButton,
    GlFormGroup,
    GlFormInput,
    GlFormInputGroup,
    GlFormRadioGroup,
    GlIcon,
    GlInputGroupText,
    GlLoadingIcon,
    GlModal,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    fullPath: {
      from: 'projectFullPath',
    },
  },
  props: {
    targetUrl: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isCreatingValidation: false,
      isValidating: false,
      hasValidationError: false,
      validationMethod: DAST_SITE_VALIDATION_METHOD_TEXT_FILE,
      validationPath: '',
      isCreatingToken: false,
      token: null,
      tokenId: null,
    };
  },
  computed: {
    validationMethodOptions() {
      const isHttpHeaderValidationEnabled = this.glFeatures
        .securityOnDemandScansHttpHeaderValidation;

      const enabledValidationMethods = omit(DAST_SITE_VALIDATION_METHODS, [
        !isHttpHeaderValidationEnabled ? DAST_SITE_VALIDATION_METHOD_HTTP_HEADER : '',
      ]);

      return Object.values(enabledValidationMethods);
    },
    urlObject() {
      try {
        return new URL(this.targetUrl);
      } catch {
        return {};
      }
    },
    origin() {
      return this.urlObject.origin ? `${this.urlObject.origin}/` : '';
    },
    path() {
      return cleanLeadingSeparator(this.urlObject.pathname || '');
    },
    isTextFileValidation() {
      return this.validationMethod === DAST_SITE_VALIDATION_METHOD_TEXT_FILE;
    },
    isHttpHeaderValidation() {
      return this.validationMethod === DAST_SITE_VALIDATION_METHOD_HTTP_HEADER;
    },
    textFileName() {
      return `GitLab-DAST-Site-Validation-${this.token}.txt`;
    },
    locationStepLabel() {
      return DAST_SITE_VALIDATION_METHODS[this.validationMethod].i18n.locationStepLabel;
    },
    httpHeader() {
      return `${DAST_SITE_VALIDATION_HTTP_HEADER_KEY}: ${this.token}`;
    },
  },
  watch: {
    targetUrl: {
      immediate: true,
      handler: 'createValidationToken',
    },
  },
  created() {
    this.unsubscribe = this.$watch(
      () => [this.token, this.validationMethod],
      this.updateValidationPath,
      {
        immediate: true,
      },
    );
  },
  methods: {
    updateValidationPath() {
      this.validationPath = this.isTextFileValidation
        ? this.getTextFileValidationPath()
        : this.path;
    },
    getTextFileValidationPath() {
      return joinPaths(stripPathTail(this.path), this.textFileName);
    },
    onValidationPathInput() {
      this.unsubscribe();
    },
    downloadTextFile() {
      download({ fileName: this.textFileName, fileData: btoa(this.token) });
    },
    async createValidationToken() {
      this.isCreatingToken = true;
      try {
        const {
          data: {
            dastSiteTokenCreate: { errors, id, token },
          },
        } = await this.$apollo.mutate({
          mutation: dastSiteTokenCreateMutation,
          variables: {
            fullPath: this.fullPath,
            targetUrl: this.targetUrl,
          },
        });
        if (errors?.length) {
          this.onError();
        } else {
          this.token = token;
          this.tokenId = id;
        }
        this.isCreatingToken = false;
      } catch (exception) {
        this.onError(exception);
        this.isCreatingToken = false;
      }
    },
    async validate() {
      this.hasValidationError = false;
      this.isCreatingValidation = true;
      this.isValidating = true;
      this.$emit('validate-site', this.targetUrl);
      try {
        const {
          data: {
            dastSiteValidationCreate: { status, errors },
          },
        } = await this.$apollo.mutate({
          mutation: dastSiteValidationCreateMutation,
          variables: {
            projectFullPath: this.fullPath,
            dastSiteTokenId: this.tokenId,
            validationPath: this.validationPath,
            validationStrategy: this.validationMethod,
          },
        });
        if (errors?.length) {
          this.onError();
        } else if (status === DAST_SITE_VALIDATION_STATUS.PASSED) {
          this.onSuccess();
        } else {
          this.isCreatingValidation = false;
        }
      } catch (exception) {
        this.onError(exception);
      }
    },
    onSuccess() {
      this.isCreatingValidation = false;
      this.isValidating = false;
      this.$emit('success');
    },
    onError(exception = null) {
      if (exception !== null) {
        Sentry.captureException(exception);
      }
      this.isCreatingValidation = false;
      this.isValidating = false;
      this.hasValidationError = true;
    },
  },
};
</script>

<template>
  <!-- TODO: Change translation namespaces? -->
  <gl-modal
    modal-id="dast-site-validation-modal"
    :title="s__('DastProfiles|Validate target site')"
    :ok-title="s__('DastProfiles|Validate')"
    :cancel-title="__('Cancel')"
    @primary="validate"
  >
    <gl-form-group :label="s__('DastProfiles|Step 1 - Choose site validation method')">
      <gl-form-radio-group v-model="validationMethod" :options="validationMethodOptions" />
    </gl-form-group>
    <gl-form-group
      v-if="isTextFileValidation"
      :label="s__('DastProfiles|Step 2 - Add following text to the target site')"
    >
      <gl-button
        variant="info"
        category="secondary"
        size="small"
        icon="download"
        data-testid="download-dast-text-file-validation-button"
        :aria-label="s__('DastProfiles|Download validation text file')"
        @click="downloadTextFile()"
      >
        {{ textFileName }}
      </gl-button>
    </gl-form-group>
    <gl-form-group
      v-else-if="isHttpHeaderValidation"
      :label="s__('DastProfiles|Step 2 - Add following HTTP header to your site')"
    >
      <code class="gl-p-3 gl-bg-black gl-text-white">{{ httpHeader }}</code>
      <clipboard-button
        :text="httpHeader"
        :title="s__('DastProfiles|Copy HTTP header to clipboard')"
      />
    </gl-form-group>
    <gl-form-group :label="locationStepLabel" class="mw-460">
      <gl-form-input-group>
        <template #prepend>
          <gl-input-group-text data-testid="dast-site-validation-path-prefix">{{
            origin
          }}</gl-input-group-text>
        </template>
        <gl-form-input
          v-model="validationPath"
          class="gl-bg-white!"
          data-testid="dast-site-validation-path-input"
          @input="onValidationPathInput()"
        />
      </gl-form-input-group>
    </gl-form-group>

    <hr />

    <gl-button
      variant="success"
      category="secondary"
      data-testid="validate-dast-site-button"
      :disabled="isValidating"
      @click="validate"
    >
      {{ s__('DastProfiles|Validate') }}
    </gl-button>
    <span
      class="gl-ml-3"
      :class="{ 'gl-text-orange-600': isValidating, 'gl-text-red-500': hasValidationError }"
    >
      <template v-if="isValidating">
        <gl-loading-icon inline /> {{ s__('DastProfiles|Validating...') }}
      </template>
      <template v-else-if="hasValidationError">
        <gl-icon name="status_failed" />
        {{
          s__(
            'DastProfiles|Validation failed, please make sure that you follow the steps above with the chosen method.',
          )
        }}
      </template>
    </span>
  </gl-modal>
</template>
