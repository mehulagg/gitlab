<script>
import {
  GlAlert,
  GlButton,
  GlCard,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlFormTextarea,
  GlLink,
  GlSkeletonLoader,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import {
  SCAN_TYPE_LABEL,
  SCAN_TYPE,
} from 'ee/security_configuration/dast_scanner_profiles/constants';
import { DAST_SITE_VALIDATION_STATUS } from 'ee/security_configuration/dast_site_validation/constants';
import { initFormField } from 'ee/security_configuration/utils';
import { s__ } from '~/locale';
import validation from '~/vue_shared/directives/validation';
import * as Sentry from '~/sentry/wrapper';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { redirectTo, queryToObject } from '~/lib/utils/url_utility';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import {
  ERROR_RUN_SCAN,
  ERROR_FETCH_SCANNER_PROFILES,
  ERROR_FETCH_SITE_PROFILES,
  ERROR_MESSAGES,
  SCANNER_PROFILES_QUERY,
  SITE_PROFILES_QUERY,
  SITE_PROFILES_EXTENDED_QUERY,
  TYPE_SITE_PROFILE,
  TYPE_SCANNER_PROFILE,
} from '../settings';
import dastScanCreateMutation from '../graphql/dast_scan_create.mutation.graphql';
import dastScanUpdateMutation from '../graphql/dast_scan_update.mutation.graphql';
import dastOnDemandScanCreateMutation from '../graphql/dast_on_demand_scan_create.mutation.graphql';
import ProfileSelectorSummaryCell from './profile_selector/summary_cell.vue';
import ScannerProfileSelector from './profile_selector/scanner_profile_selector.vue';
import SiteProfileSelector from './profile_selector/site_profile_selector.vue';

const createProfilesApolloOptions = (name, field, { fetchQuery, fetchError }) => ({
  query: fetchQuery,
  variables() {
    return {
      fullPath: this.projectPath,
    };
  },
  update(data) {
    const edges = data?.project?.[name]?.edges ?? [];
    if (edges.length === 1) {
      this[field] = edges[0].node.id;
    }
    return edges.map(({ node }) => node);
  },
  error(e) {
    Sentry.captureException(e);
    this.showErrors(fetchError);
  },
});

export default {
  SCAN_TYPE_LABEL,
  saveAndRunScanBtnId: 'scan-submit-button',
  saveScanBtnId: 'scan-save-button',
  components: {
    ProfileSelectorSummaryCell,
    ScannerProfileSelector,
    SiteProfileSelector,
    GlAlert,
    GlButton,
    GlCard,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
    GlLink,
    GlSkeletonLoader,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    validation: validation(),
  },
  mixins: [glFeatureFlagsMixin()],
  apollo: {
    scannerProfiles: createProfilesApolloOptions(
      'scannerProfiles',
      'selectedScannerProfileId',
      SCANNER_PROFILES_QUERY,
    ),
    siteProfiles() {
      return createProfilesApolloOptions(
        'siteProfiles',
        'selectedSiteProfileId',
        this.glFeatures.securityDastSiteProfilesAdditionalFields
          ? SITE_PROFILES_EXTENDED_QUERY
          : SITE_PROFILES_QUERY,
      );
    },
  },
  props: {
    helpPagePath: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    defaultBranch: {
      type: String,
      required: false,
      default: '',
    },
    dastScan: {
      type: Object,
      required: false,
      default: null,
    },
  },
  inject: {
    dastSiteValidationDocsPath: {
      default: '',
    },
  },
  data() {
    const savedScansFields = this.glFeatures.dastSavedScans
      ? {
          form: {
            showValidation: false,
            state: false,
            fields: {
              name: initFormField({ value: this.dastScan?.name ?? '' }),
              description: initFormField({
                value: this.dastScan?.description ?? '',
                required: false,
                skipValidation: true,
              }),
            },
          },
        }
      : {};
    return {
      ...savedScansFields,
      scannerProfiles: [],
      siteProfiles: [],
      selectedScannerProfileId: this.dastScan?.scannerProfileId || null,
      selectedSiteProfileId: this.dastScan?.siteProfileId || null,
      loading: false,
      errorType: null,
      errors: [],
      showAlert: false,
    };
  },
  computed: {
    isEdit() {
      return Boolean(this.dastScan?.id);
    },
    title() {
      return this.isEdit
        ? s__('OnDemandScans|Edit on-demand DAST scan')
        : s__('OnDemandScans|New on-demand DAST scan');
    },
    selectedScannerProfile() {
      return this.selectedScannerProfileId
        ? this.scannerProfiles.find(({ id }) => id === this.selectedScannerProfileId)
        : null;
    },
    selectedSiteProfile() {
      return this.selectedSiteProfileId
        ? this.siteProfiles.find(({ id }) => id === this.selectedSiteProfileId)
        : null;
    },
    errorMessage() {
      return ERROR_MESSAGES[this.errorType] || null;
    },
    isLoadingProfiles() {
      return ['scannerProfiles', 'siteProfiles'].some((name) => this.$apollo.queries[name].loading);
    },
    failedToLoadProfiles() {
      return [ERROR_FETCH_SCANNER_PROFILES, ERROR_FETCH_SITE_PROFILES].includes(this.errorType);
    },
    someFieldEmpty() {
      const { selectedScannerProfile, selectedSiteProfile } = this;
      return !selectedScannerProfile || !selectedSiteProfile;
    },
    isActiveScannerProfile() {
      return this.selectedScannerProfile?.scanType === SCAN_TYPE.ACTIVE;
    },
    isValidatedSiteProfile() {
      return this.selectedSiteProfile?.validationStatus === DAST_SITE_VALIDATION_STATUS.PASSED;
    },
    hasProfilesConflict() {
      return (
        this.glFeatures.securityOnDemandScansSiteValidation &&
        !this.someFieldEmpty &&
        this.isActiveScannerProfile &&
        !this.isValidatedSiteProfile
      );
    },
    isFormInvalid() {
      return this.someFieldEmpty || this.hasProfilesConflict;
    },
    isSubmitButtonDisabled() {
      const {
        isFormInvalid,
        loading,
        $options: { saveAndRunScanBtnId },
      } = this;
      return isFormInvalid || (loading && loading !== saveAndRunScanBtnId);
    },
    isSaveButtonDisabled() {
      const {
        isFormInvalid,
        loading,
        $options: { saveScanBtnId },
      } = this;
      return isFormInvalid || (loading && loading !== saveScanBtnId);
    },
  },
  created() {
    const params = queryToObject(window.location.search);

    this.selectedSiteProfileId = params.site_profile_id
      ? convertToGraphQLId(TYPE_SITE_PROFILE, params.site_profile_id)
      : this.selectedSiteProfileId;
    this.selectedScannerProfileId = params.scanner_profile_id
      ? convertToGraphQLId(TYPE_SCANNER_PROFILE, params.scanner_profile_id)
      : this.selectedScannerProfileId;
  },
  methods: {
    onSubmit({ runAfterCreate = true, button = this.$options.saveAndRunScanBtnId } = {}) {
      if (this.glFeatures.dastSavedScans) {
        this.form.showValidation = true;
        if (!this.form.state) {
          return;
        }
      }

      this.loading = button;
      this.hideErrors();
      let mutation = dastOnDemandScanCreateMutation;
      let reponseType = 'dastOnDemandScanCreate';
      let input = {
        fullPath: this.projectPath,
        dastScannerProfileId: this.selectedScannerProfile.id,
        dastSiteProfileId: this.selectedSiteProfile.id,
      };
      if (this.glFeatures.dastSavedScans) {
        mutation = this.isEdit ? dastScanUpdateMutation : dastScanCreateMutation;
        reponseType = this.isEdit ? 'dastScanUpdate' : 'dastScanCreate';
        input = {
          ...input,
          ...(this.isEdit ? { id: this.dastScan.id } : {}),
          name: this.form.fields.name.value,
          description: this.form.fields.description.value,
          runAfterCreate,
        };
      }

      this.$apollo
        .mutate({
          mutation,
          variables: {
            input,
          },
        })
        .then(({ data }) => {
          const response = data[reponseType];
          const { errors } = response;
          if (errors?.length) {
            this.showErrors(ERROR_RUN_SCAN, errors);
            this.loading = false;
          } else if (this.glFeatures.dastSavedScans && !runAfterCreate) {
            redirectTo(response.dastScan.editPath);
          } else {
            redirectTo(response.pipelineUrl);
          }
        })
        .catch((e) => {
          Sentry.captureException(e);
          this.showErrors(ERROR_RUN_SCAN);
          this.loading = false;
        });
    },
    showErrors(errorType, errors = []) {
      this.errorType = errorType;
      this.errors = errors;
      this.showAlert = true;
    },
    hideErrors() {
      this.errorType = null;
      this.errors = [];
      this.showAlert = false;
    },
  },
};
</script>

<template>
  <gl-form novalidate @submit.prevent="onSubmit()">
    <header class="gl-mb-6">
      <h2>{{ title }}</h2>
      <p>
        <gl-sprintf
          :message="
            s__(
              'OnDemandScans|On-demand scans run outside the DevOps cycle and find vulnerabilities in your projects. %{learnMoreLinkStart}Learn more%{learnMoreLinkEnd}',
            )
          "
        >
          <template #learnMoreLink="{ content }">
            <gl-link :href="helpPagePath">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </p>
    </header>

    <gl-alert
      v-if="showAlert"
      variant="danger"
      class="gl-mb-5"
      data-testid="on-demand-scan-error"
      :dismissible="!failedToLoadProfiles"
      @dismiss="hideErrors"
    >
      {{ errorMessage }}
      <ul v-if="errors.length" class="gl-mt-3 gl-mb-0">
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>
    </gl-alert>

    <template v-if="isLoadingProfiles">
      <gl-skeleton-loader v-if="glFeatures.dastSavedScans" :width="1248" :height="180">
        <rect x="0" y="0" width="100" height="15" rx="4" />
        <rect x="0" y="24" width="460" height="32" rx="4" />
        <rect x="0" y="71" width="100" height="15" rx="4" />
        <rect x="0" y="95" width="460" height="72" rx="4" />
      </gl-skeleton-loader>
      <gl-card v-for="i in 2" :key="i" class="gl-mb-5">
        <template #header>
          <gl-skeleton-loader :width="1248" :height="15">
            <rect x="0" y="0" width="300" height="15" rx="4" />
          </gl-skeleton-loader>
        </template>
        <gl-skeleton-loader :width="1248" :height="15">
          <rect x="0" y="0" width="600" height="15" rx="4" />
        </gl-skeleton-loader>
        <gl-skeleton-loader :width="1248" :height="15">
          <rect x="0" y="0" width="300" height="15" rx="4" />
        </gl-skeleton-loader>
      </gl-card>
    </template>
    <template v-else-if="!failedToLoadProfiles">
      <template v-if="glFeatures.dastSavedScans">
        <gl-form-group
          :label="s__('OnDemandScans|Scan name')"
          :invalid-feedback="form.fields.name.feedback"
        >
          <gl-form-input
            v-model="form.fields.name.value"
            v-validation:[form.showValidation]
            class="mw-460"
            data-testid="dast-scan-name-input"
            type="text"
            :placeholder="s__('OnDemandScans|My daily scan')"
            :state="form.fields.name.state"
            name="name"
            required
          />
        </gl-form-group>
        <gl-form-group :label="s__('OnDemandScans|Description')">
          <gl-form-textarea
            v-model="form.fields.description.value"
            class="mw-460"
            data-testid="dast-scan-description-input"
            :placeholder="s__(`OnDemandScans|For example: Tests the login page for SQL injections`)"
            :state="form.fields.description.state"
          />
        </gl-form-group>
      </template>
      <scanner-profile-selector
        v-model="selectedScannerProfileId"
        class="gl-mb-5"
        :profiles="scannerProfiles"
      >
        <template v-if="selectedScannerProfile" #summary>
          <div class="row">
            <profile-selector-summary-cell
              :class="{ 'gl-text-red-500': hasProfilesConflict }"
              :label="s__('DastProfiles|Scan mode')"
              :value="$options.SCAN_TYPE_LABEL[selectedScannerProfile.scanType]"
            />
          </div>
          <div class="row">
            <profile-selector-summary-cell
              :label="s__('DastProfiles|Spider timeout')"
              :value="n__('%d minute', '%d minutes', selectedScannerProfile.spiderTimeout)"
            />
            <profile-selector-summary-cell
              :label="s__('DastProfiles|Target timeout')"
              :value="n__('%d second', '%d seconds', selectedScannerProfile.targetTimeout)"
            />
          </div>
          <div class="row">
            <profile-selector-summary-cell
              :label="s__('DastProfiles|AJAX spider')"
              :value="selectedScannerProfile.useAjaxSpider ? __('On') : __('Off')"
            />
            <profile-selector-summary-cell
              :label="s__('DastProfiles|Debug messages')"
              :value="
                selectedScannerProfile.showDebugMessages
                  ? s__('DastProfiles|Show debug messages')
                  : s__('DastProfiles|Hide debug messages')
              "
            />
          </div>
        </template>
      </scanner-profile-selector>
      <site-profile-selector
        v-model="selectedSiteProfileId"
        class="gl-mb-5"
        :profiles="siteProfiles"
      >
        <template v-if="selectedSiteProfile" #summary>
          <div class="row">
            <profile-selector-summary-cell
              :class="{ 'gl-text-red-500': hasProfilesConflict }"
              :label="s__('DastProfiles|Target URL')"
              :value="selectedSiteProfile.targetUrl"
            />
          </div>
          <template v-if="glFeatures.securityDastSiteProfilesAdditionalFields">
            <template v-if="selectedSiteProfile.auth.enabled">
              <div class="row">
                <profile-selector-summary-cell
                  :label="s__('DastProfiles|Authentication URL')"
                  :value="selectedSiteProfile.auth.url"
                />
              </div>
              <div class="row">
                <profile-selector-summary-cell
                  :label="s__('DastProfiles|Username')"
                  :value="selectedSiteProfile.auth.username"
                />
              </div>
              <div class="row">
                <profile-selector-summary-cell
                  :label="s__('DastProfiles|Username form field')"
                  :value="selectedSiteProfile.auth.usernameField"
                />
                <profile-selector-summary-cell
                  :label="s__('DastProfiles|Password form field')"
                  :value="selectedSiteProfile.auth.passwordField"
                />
              </div>
            </template>
            <div class="row">
              <profile-selector-summary-cell
                :label="s__('DastProfiles|Excluded URLs')"
                :value="selectedSiteProfile.excludedUrls"
              />
              <profile-selector-summary-cell
                :label="s__('DastProfiles|Request headers')"
                :value="selectedSiteProfile.requestHeaders"
              />
            </div>
          </template>
        </template>
      </site-profile-selector>

      <gl-alert
        v-if="hasProfilesConflict"
        :title="s__('OnDemandScans|You cannot run an active scan against an unvalidated site.')"
        :dismissible="false"
        variant="danger"
        data-testid="on-demand-scans-profiles-conflict-alert"
      >
        <gl-sprintf
          :message="
            s__(
              'OnDemandScans|You can either choose a passive scan or validate the target site in your chosen site profile. %{docsLinkStart}Learn more about site validation.%{docsLinkEnd}',
            )
          "
        >
          <template #docsLink="{ content }">
            <gl-link :href="dastSiteValidationDocsPath">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </gl-alert>

      <div class="gl-mt-6 gl-pt-6">
        <gl-button
          type="submit"
          variant="success"
          class="js-no-auto-disable"
          data-testid="on-demand-scan-submit-button"
          :disabled="isSubmitButtonDisabled"
          :loading="loading === $options.saveAndRunScanBtnId"
        >
          {{
            glFeatures.dastSavedScans
              ? s__('OnDemandScans|Save and run scan')
              : s__('OnDemandScans|Run scan')
          }}
        </gl-button>
        <gl-button
          v-if="glFeatures.dastSavedScans"
          variant="success"
          category="secondary"
          data-testid="on-demand-scan-save-button"
          :disabled="isSaveButtonDisabled"
          :loading="loading === $options.saveScanBtnId"
          @click="onSubmit({ runAfterCreate: false, button: $options.saveScanBtnId })"
        >
          {{ s__('OnDemandScans|Save scan') }}
        </gl-button>
      </div>
    </template>
  </gl-form>
</template>
