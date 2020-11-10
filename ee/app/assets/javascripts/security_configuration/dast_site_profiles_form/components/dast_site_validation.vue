<script>
import {
  GlAlert,
  GlButton,
  GlCard,
  GlFormGroup,
  GlFormInput,
  GlFormInputGroup,
  GlFormRadioGroup,
  GlIcon,
  GlInputGroupText,
  GlLoadingIcon,
} from '@gitlab/ui';
import { omit } from 'lodash';
import * as Sentry from '~/sentry/wrapper';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import download from '~/lib/utils/downloader';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { cleanLeadingSeparator, joinPaths, stripPathTail } from '~/lib/utils/url_utility';
import { fetchPolicies } from '~/lib/graphql';
import {
  DAST_SITE_VALIDATION_HTTP_HEADER_KEY,
  DAST_SITE_VALIDATION_METHOD_HTTP_HEADER,
  DAST_SITE_VALIDATION_METHOD_TEXT_FILE,
  DAST_SITE_VALIDATION_METHODS,
  DAST_SITE_VALIDATION_STATUS,
  DAST_SITE_VALIDATION_POLL_INTERVAL,
} from '../constants';
import dastSiteValidationCreateMutation from '../graphql/dast_site_validation_create.mutation.graphql';
import dastSiteValidationQuery from '../graphql/dast_site_validation.query.graphql';

export default {
  name: 'DastSiteValidation',
  components: {
    ClipboardButton,
    GlAlert,
    GlButton,
    GlCard,
    GlFormGroup,
    GlFormInput,
    GlFormInputGroup,
    GlFormRadioGroup,
    GlIcon,
    GlInputGroupText,
    GlLoadingIcon,
  },
  mixins: [glFeatureFlagsMixin()],
  apollo: {
    dastSiteValidation: {
      query: dastSiteValidationQuery,
      variables() {
        return {
          fullPath: this.fullPath,
          targetUrl: this.targetUrl,
        };
      },
      manual: true,
      result({
        data: {
          project: {
            dastSiteValidation: { status },
          },
        },
      }) {
        if (status === DAST_SITE_VALIDATION_STATUS.PASSED) {
          this.onSuccess();
        }

        if (status === DAST_SITE_VALIDATION_STATUS.FAILED) {
          this.onError();
        }
      },
      skip() {
        return !(this.isCreatingValidation || this.isValidating);
      },
      pollInterval: DAST_SITE_VALIDATION_POLL_INTERVAL,
      fetchPolicy: fetchPolicies.NETWORK_ONLY,
      error(e) {
        this.onError(e);
      },
    },
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
    tokenId: {
      type: String,
      required: false,
      default: null,
    },
    token: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      isCreatingValidation: false,
      isValidating: false,
      hasValidationError: false,
      validationMethod: DAST_SITE_VALIDATION_METHOD_TEXT_FILE,
      validationPath: '',
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
    targetUrl() {
      this.hasValidationError = false;
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
    async validate() {
      this.hasValidationError = false;
      this.isCreatingValidation = true;
      this.isValidating = true;
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
  <gl-card class="gl-bg-gray-10">
    <gl-alert variant="warning" :dismissible="false" class="gl-mb-3">
      {{ s__('DastProfiles|Site is not validated yet, please follow the steps.') }}
    </gl-alert>
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
  </gl-card>
</template>
