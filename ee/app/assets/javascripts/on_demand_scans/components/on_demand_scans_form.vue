<script>
import {
  GlAlert,
  GlButton,
  GlCard,
  GlForm,
  GlLink,
  GlSkeletonLoader,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import * as Sentry from '~/sentry/wrapper';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { redirectTo } from '~/lib/utils/url_utility';
import {
  ERROR_RUN_SCAN,
  ERROR_FETCH_SCANNER_PROFILES,
  ERROR_FETCH_SITE_PROFILES,
  ERROR_MESSAGES,
  SCANNER_PROFILES_QUERY,
  SITE_PROFILES_QUERY,
} from '../settings';
import dastOnDemandScanCreateMutation from '../graphql/dast_on_demand_scan_create.mutation.graphql';
import OnDemandScansScannerProfileSelector from './profile_selector/scanner_profile_selector.vue';
import OnDemandScansSiteProfileSelector from './profile_selector/site_profile_selector.vue';

const createProfilesApolloOptions = (name, { fetchQuery, fetchError }) => ({
  query: fetchQuery,
  variables() {
    return {
      fullPath: this.projectPath,
    };
  },
  update(data) {
    const edges = data?.project?.[name]?.edges ?? [];
    return edges.map(({ node }) => node);
  },
  error(e) {
    Sentry.captureException(e);
    this.showErrors(fetchError);
  },
});

export default {
  components: {
    OnDemandScansScannerProfileSelector,
    OnDemandScansSiteProfileSelector,
    GlAlert,
    GlButton,
    GlCard,
    GlForm,
    GlLink,
    GlSkeletonLoader,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  apollo: {
    scannerProfiles: createProfilesApolloOptions('scannerProfiles', SCANNER_PROFILES_QUERY),
    siteProfiles: createProfilesApolloOptions('siteProfiles', SITE_PROFILES_QUERY),
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
        [SCANNER_PROFILES_QUERY.field]: null,
        [SITE_PROFILES_QUERY.field]: null,
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
      return ['scannerProfiles', 'siteProfiles'].some(name => this.$apollo.queries[name].loading);
    },
    failedToLoadProfiles() {
      return [ERROR_FETCH_SCANNER_PROFILES, ERROR_FETCH_SITE_PROFILES].includes(this.errorType);
    },
    someFieldEmpty() {
      return Object.values(this.form).some(value => !value);
    },
  },
  methods: {
    onSubmit() {
      this.loading = true;
      this.hideErrors();

      this.$apollo
        .mutate({
          mutation: dastOnDemandScanCreateMutation,
          variables: {
            fullPath: this.projectPath,
            ...this.form,
          },
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
      <on-demand-scans-scanner-profile-selector
        v-model="form.dastScannerProfileId"
        :profiles="scannerProfiles"
      />
      <on-demand-scans-site-profile-selector
        v-model="form.dastSiteProfileId"
        :profiles="siteProfiles"
      />

      <div class="gl-mt-6 gl-pt-6">
        <gl-button
          type="submit"
          variant="success"
          class="js-no-auto-disable"
          data-testid="on-demand-scan-submit-button"
          :disabled="someFieldEmpty"
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
