<script>
import * as Sentry from '@sentry/browser';
import {
  GlAlert,
  GlButton,
  GlCard,
  GlForm,
  GlFormGroup,
  GlLink,
  GlDropdown,
  GlDropdownItem,
  GlSkeletonLoader,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import dastScannerProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { s__ } from '~/locale';
import { redirectTo } from '~/lib/utils/url_utility';
import dastOnDemandScanCreateMutation from '../graphql/dast_on_demand_scan_create.mutation.graphql';
import DismissibleFeedbackAlert from '~/vue_shared/components/dismissible_feedback_alert.vue';

const ERROR_RUN_SCAN = 'ERROR_RUN_SCAN';
const ERROR_FETCH_SCANNER_PROFILES = 'ERROR_FETCH_SCANNER_PROFILES';
const ERROR_FETCH_SITE_PROFILES = 'ERROR_FETCH_SITE_PROFILES';

const ERROR_MESSAGES = {
  [ERROR_RUN_SCAN]: s__('OnDemandScans|Could not run the scan. Please try again.'),
  [ERROR_FETCH_SCANNER_PROFILES]: s__(
    'OnDemandScans|Could not fetch scanner profiles. Please refresh the page, or try again later.',
  ),
  [ERROR_FETCH_SITE_PROFILES]: s__(
    'OnDemandScans|Could not fetch site profiles. Please refresh the page, or try again later.',
  ),
};

const initField = value => ({
  value,
  state: null,
  feedback: null,
});

export default {
  components: {
    GlAlert,
    GlButton,
    GlCard,
    GlForm,
    GlFormGroup,
    GlLink,
    GlDropdown,
    GlDropdownItem,
    GlSkeletonLoader,
    GlSprintf,
    DismissibleFeedbackAlert,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  apollo: {
    scannerProfiles: {
      query: dastScannerProfilesQuery,
      variables() {
        return {
          fullPath: this.projectPath,
        };
      },
      update(data) {
        const scannerProfilesEdges = data?.project?.scannerProfiles?.edges ?? [];
        return scannerProfilesEdges.map(({ node }) => node);
      },
      error(e) {
        Sentry.captureException(e);
        this.showErrors(ERROR_FETCH_SCANNER_PROFILES);
      },
    },
    siteProfiles: {
      query: dastSiteProfilesQuery,
      variables() {
        return {
          fullPath: this.projectPath,
        };
      },
      update(data) {
        const siteProfileEdges = data?.project?.siteProfiles?.edges ?? [];
        return siteProfileEdges.map(({ node }) => node);
      },
      error(e) {
        Sentry.captureException(e);
        this.showErrors(ERROR_FETCH_SITE_PROFILES);
      },
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
      required: true,
    },
  },
  inject: {
    scannerProfilesLibraryPath: {
      default: '',
    },
    siteProfilesLibraryPath: {
      default: '',
    },
    newScannerProfilePath: {
      default: '',
    },
    newSiteProfilePath: {
      default: '',
    },
  },
  data() {
    return {
      scannerProfiles: [],
      siteProfiles: [],
      form: {
        dastScannerProfileId: initField(null),
        dastSiteProfileId: initField(null),
      },
      loading: false,
      errorType: null,
      errors: [],
      showAlert: false,
    };
  },
  computed: {
    errorMessage() {
      return ERROR_MESSAGES[this.errorType] || null;
    },
    isLoadingProfiles() {
      return ['scanner', 'site'].some(
        profileType => this.$apollo.queries[`${profileType}Profiles`].loading,
      );
    },
    failedToLoadProfiles() {
      return [ERROR_FETCH_SCANNER_PROFILES, ERROR_FETCH_SITE_PROFILES].includes(this.errorType);
    },
    formData() {
      return {
        fullPath: this.projectPath,
        ...Object.fromEntries(Object.entries(this.form).map(([key, { value }]) => [key, value])),
      };
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
    selectedScannerProfile() {
      const selectedScannerProfile = this.form.dastScannerProfileId.value;
      return selectedScannerProfile === null
        ? null
        : this.scannerProfiles.find(({ id }) => id === selectedScannerProfile);
    },
    selectedSiteProfile() {
      const selectedSiteProfileId = this.form.dastSiteProfileId.value;
      return selectedSiteProfileId === null
        ? null
        : this.siteProfiles.find(({ id }) => id === selectedSiteProfileId);
    },
    scannerProfileText() {
      const { selectedScannerProfile } = this;
      return selectedScannerProfile
        ? selectedScannerProfile.profileName
        : s__('OnDemandScans|Select one of the existing profiles');
    },
    siteProfileText() {
      const { selectedSiteProfile } = this;
      return selectedSiteProfile
        ? `${selectedSiteProfile.profileName}: ${selectedSiteProfile.targetUrl}`
        : s__('OnDemandScans|Select one of the existing profiles');
    },
  },
  methods: {
    setScannerProfile({ id }) {
      this.form.dastScannerProfileId.value = id;
    },
    setSiteProfile({ id }) {
      this.form.dastSiteProfileId.value = id;
    },
    onSubmit() {
      this.loading = true;
      this.hideErrors();

      this.$apollo
        .mutate({
          mutation: dastOnDemandScanCreateMutation,
          variables: this.formData,
        })
        .then(({ data: { dastOnDemandScanCreate: { pipelineUrl, errors } } }) => {
          if (errors?.length) {
            this.showErrors(ERROR_RUN_SCAN, errors);
            this.loading = false;
          } else {
            redirectTo(pipelineUrl);
          }
        })
        .catch(e => {
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
  <gl-form @submit.prevent="onSubmit">
    <!--
      This is a temporary change to solicit feedback from users
      and shall be removed in https://gitlab.com/gitlab-org/gitlab/-/issues/255889
    -->
    <dismissible-feedback-alert
      feature-name="on-demand DAST scans"
      feedback-link="https://gitlab.com/gitlab-org/gitlab/-/issues/249684"
    />

    <header class="gl-mb-6">
      <h2>{{ s__('OnDemandScans|New on-demand DAST scan') }}</h2>
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
      <gl-card v-for="i in 2" :key="i">
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
      <gl-card>
        <template #header>
          <div class="row">
            <div class="col-7">
              <h3 class="gl-font-lg gl-display-inline">
                {{ s__('OnDemandScans|Scanner settings') }}
              </h3>
            </div>
            <div class="col-5 gl-text-right">
              <gl-button
                :href="scannerProfiles.length ? scannerProfilesLibraryPath : null"
                :disabled="!scannerProfiles.length"
                variant="success"
                category="secondary"
                size="small"
                data-testid="manage-scanner-profiles-button"
              >
                {{ s__('OnDemandScans|Manage profiles') }}
              </gl-button>
            </div>
          </div>
        </template>

        <gl-form-group v-if="scannerProfiles.length">
          <template #label>
            {{ s__('OnDemandScans|Use existing scanner profile') }}
          </template>
          <gl-dropdown
            v-model="form.dastScannerProfileId.value"
            :text="scannerProfileText"
            class="mw-460"
            data-testid="scanner-profiles-dropdown"
          >
            <gl-dropdown-item
              v-for="scannerProfile in scannerProfiles"
              :key="scannerProfile.id"
              :is-checked="form.dastScannerProfileId.value === scannerProfile.id"
              is-check-item
              @click="setScannerProfile(scannerProfile)"
            >
              {{ scannerProfile.profileName }}
            </gl-dropdown-item>
          </gl-dropdown>
          <template v-if="selectedScannerProfile">
            <hr />
            <div data-testid="scanner-profile-summary">
              <div class="row">
                <div class="col-md-6">
                  <div class="row">
                    <div class="col-md-3">{{ s__('DastProfiles|Scan mode') }}:</div>
                    <div class="col-md-9">
                      <strong>{{ s__('DastProfiles|Passive') }}</strong>
                    </div>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6">
                  <div class="row">
                    <div class="col-md-3">{{ s__('DastProfiles|Spider timeout') }}:</div>
                    <div class="col-md-9">
                      <strong>
                        {{ n__('%d minute', '%d minutes', selectedScannerProfile.spiderTimeout) }}
                      </strong>
                    </div>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="row">
                    <div class="col-md-3">{{ s__('DastProfiles|Target timeout') }}:</div>
                    <div class="col-md-9">
                      <strong>
                        {{ n__('%d second', '%d seconds', selectedScannerProfile.targetTimeout) }}
                      </strong>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </gl-form-group>
        <template v-else>
          <p class="gl-text-gray-700">
            {{
              s__(
                'OnDemandScans|No profile yet. In order to create a new scan, you need to have at least one completed scanner profile.',
              )
            }}
          </p>
          <gl-button
            :href="newScannerProfilePath"
            variant="success"
            category="secondary"
            data-testid="create-scanner-profile-link"
          >
            {{ s__('OnDemandScans|Create a new scanner profile') }}
          </gl-button>
        </template>
      </gl-card>

      <gl-card>
        <template #header>
          <div class="row">
            <div class="col-7">
              <h3 class="gl-font-lg gl-display-inline">{{ s__('OnDemandScans|Site profiles') }}</h3>
            </div>
            <div class="col-5 gl-text-right">
              <gl-button
                :href="siteProfiles.length ? siteProfilesLibraryPath : null"
                :disabled="!siteProfiles.length"
                variant="success"
                category="secondary"
                size="small"
                data-testid="manage-site-profiles-button"
              >
                {{ s__('OnDemandScans|Manage profiles') }}
              </gl-button>
            </div>
          </div>
        </template>
        <gl-form-group v-if="siteProfiles.length">
          <template #label>
            {{ s__('OnDemandScans|Use existing site profile') }}
          </template>
          <gl-dropdown
            v-model="form.dastSiteProfileId.value"
            :text="siteProfileText"
            class="mw-460"
            data-testid="site-profiles-dropdown"
          >
            <gl-dropdown-item
              v-for="siteProfile in siteProfiles"
              :key="siteProfile.id"
              :is-checked="form.dastSiteProfileId.value === siteProfile.id"
              is-check-item
              @click="setSiteProfile(siteProfile)"
            >
              {{ siteProfile.profileName }}
            </gl-dropdown-item>
          </gl-dropdown>
          <template v-if="selectedSiteProfile">
            <hr />
            <div class="row" data-testid="site-profile-summary">
              <div class="col-md-6">
                <div class="row">
                  <div class="col-md-3">{{ s__('DastProfiles|Target URL') }}:</div>
                  <div class="col-md-9 gl-font-weight-bold">
                    {{ selectedSiteProfile.targetUrl }}
                  </div>
                </div>
              </div>
            </div>
          </template>
        </gl-form-group>
        <template v-else>
          <p class="gl-text-gray-700">
            {{
              s__(
                'OnDemandScans|No profile yet. In order to create a new scan, you need to have at least one completed site profile.',
              )
            }}
          </p>
          <gl-button
            :href="newSiteProfilePath"
            variant="success"
            category="secondary"
            data-testid="create-site-profile-link"
          >
            {{ s__('OnDemandScans|Create a new site profile') }}
          </gl-button>
        </template>
      </gl-card>

      <div class="gl-mt-6 gl-pt-6">
        <gl-button
          type="submit"
          variant="success"
          class="js-no-auto-disable"
          :disabled="isSubmitDisabled"
          :loading="loading"
        >
          {{ s__('OnDemandScans|Run scan') }}
        </gl-button>
        <gl-button data-testid="on-demand-scan-cancel-button" @click="$emit('cancel')">
          {{ __('Cancel') }}
        </gl-button>
      </div>
    </template>
  </gl-form>
</template>
