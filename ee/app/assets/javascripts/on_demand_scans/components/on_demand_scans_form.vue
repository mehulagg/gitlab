<script>
import {
  GlAlert,
  GlButton,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlFormTextarea,
  GlLink,
  GlSprintf,
  GlSafeHtmlDirective,
  GlTooltipDirective,
} from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { initFormField } from 'ee/security_configuration/utils';
import { serializeFormObject } from '~/lib/utils/forms';
import { redirectTo } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import RefSelector from '~/ref/components/ref_selector.vue';
import { REF_TYPE_BRANCHES } from '~/ref/constants';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import validation from '~/vue_shared/directives/validation';
import dastProfileCreateMutation from '../graphql/dast_profile_create.mutation.graphql';
import dastProfileUpdateMutation from '../graphql/dast_profile_update.mutation.graphql';
import { ERROR_RUN_SCAN, ERROR_MESSAGES } from '../settings';
import DastProfilesSelector from './profile_selector/dast_profiles_selector.vue';

export const ON_DEMAND_SCANS_STORAGE_KEY = 'on-demand-scans-new-form';

export default {
  enabledRefTypes: [REF_TYPE_BRANCHES],
  saveAndRunScanBtnId: 'scan-submit-button',
  saveScanBtnId: 'scan-save-button',
  components: {
    RefSelector,
    GlAlert,
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
    GlLink,
    GlSprintf,
    LocalStorageSync,
    DastProfilesSelector,
  },
  directives: {
    SafeHtml: GlSafeHtmlDirective,
    GlTooltip: GlTooltipDirective,
    validation: validation(),
  },
  inject: {
    profilesLibraryPath: {
      default: '',
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
  data() {
    return {
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
      selectedBranch: this.dastScan?.branch?.name ?? this.defaultBranch,
      selectedScannerProfileId: this.dastScan?.scannerProfileId || null,
      selectedSiteProfileId: this.dastScan?.siteProfileId || null,
      loading: false,
      errorType: null,
      errors: [],
      showAlert: false,
      clearStorage: false,
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
    someFieldEmpty() {
      const { selectedScannerProfileId, selectedSiteProfileId } = this;
      return !selectedScannerProfileId || !selectedSiteProfileId;
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
    formFieldValues() {
      const { selectedScannerProfileId, selectedSiteProfileId, selectedBranch } = this;
      return {
        ...serializeFormObject(this.form.fields),
        selectedScannerProfileId,
        selectedSiteProfileId,
        selectedBranch,
      };
    },
    storageKey() {
      return `${this.projectPath}/${ON_DEMAND_SCANS_STORAGE_KEY}`;
    },
    errorMessage() {
      return ERROR_MESSAGES[this.errorType] || null;
    },
  },
  methods: {
    onSubmit({ runAfter = true, button = this.$options.saveAndRunScanBtnId } = {}) {
      this.form.showValidation = true;
      if (!this.form.state) {
        return;
      }

      this.loading = button;
      this.hideErrors();
      const mutation = this.isEdit ? dastProfileUpdateMutation : dastProfileCreateMutation;
      const responseType = this.isEdit ? 'dastProfileUpdate' : 'dastProfileCreate';
      const input = {
        fullPath: this.projectPath,
        dastScannerProfileId: this.selectedScannerProfileId,
        dastSiteProfileId: this.selectedSiteProfileId,
        branchName: this.selectedBranch,
        ...(this.isEdit ? { id: this.dastScan.id } : {}),
        ...serializeFormObject(this.form.fields),
        [this.isEdit ? 'runAfterUpdate' : 'runAfterCreate']: runAfter,
      };

      this.$apollo
        .mutate({
          mutation,
          variables: {
            input,
          },
        })
        .then(({ data }) => {
          const response = data[responseType];
          const { errors } = response;
          if (errors?.length) {
            this.showErrors(ERROR_RUN_SCAN, errors);
            this.loading = false;
          } else if (!runAfter) {
            redirectTo(this.profilesLibraryPath);
            this.clearStorage = true;
          } else {
            this.clearStorage = true;
            redirectTo(response.pipelineUrl);
          }
        })
        .catch((e) => {
          Sentry.captureException(e);
          this.showErrors(ERROR_RUN_SCAN);
          this.loading = false;
        });
    },
    onCancelClicked() {
      this.clearStorage = true;
      redirectTo(this.profilesLibraryPath);
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
    updateSelectedProfiles(profiles) {
      this.selectedSiteProfileId = profiles.siteProfile?.id;
      this.selectedScannerProfileId = profiles.scannerProfile?.id;
    },
    updateFromStorage(val) {
      const {
        selectedSiteProfileId,
        selectedScannerProfileId,
        name,
        description,
        selectedBranch,
      } = val;

      this.form.fields.name.value = name ?? this.form.fields.name.value;
      this.form.fields.description.value = description ?? this.form.fields.description.value;
      this.selectedBranch = selectedBranch;
      // precedence is given to profile IDs passed from the query params
      this.selectedSiteProfileId = this.selectedSiteProfileId ?? selectedSiteProfileId;
      this.selectedScannerProfileId = this.selectedScannerProfileId ?? selectedScannerProfileId;
    },
  },
};
</script>

<template>
  <gl-form novalidate @submit.prevent="onSubmit()">
    <local-storage-sync
      v-if="!isEdit"
      as-json
      :storage-key="storageKey"
      :clear="clearStorage"
      :value="formFieldValues"
      @input="updateFromStorage"
    />
    <header class="gl-mb-6">
      <div class="gl-mt-6 gl-display-flex">
        <h2 class="gl-flex-grow-1 gl-my-0">{{ title }}</h2>
        <gl-button :href="profilesLibraryPath" data-testid="manage-profiles-link">
          {{ s__('OnDemandScans|Manage DAST scans') }}
        </gl-button>
      </div>
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
        <li v-for="error in errors" :key="error" v-safe-html="error"></li>
      </ul>
    </gl-alert>

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
    <gl-form-group :label="s__('OnDemandScans|Description (optional)')">
      <gl-form-textarea
        v-model="form.fields.description.value"
        class="mw-460"
        data-testid="dast-scan-description-input"
        :placeholder="s__(`OnDemandScans|For example: Tests the login page for SQL injections`)"
        :state="form.fields.description.state"
      />
    </gl-form-group>

    <gl-form-group :label="__('Branch')">
      <ref-selector
        v-model="selectedBranch"
        data-testid="dast-scan-branch-input"
        no-flip
        :enabled-ref-types="$options.enabledRefTypes"
        :project-id="projectPath"
        :translations="{
          dropdownHeader: __('Select a branch'),
          searchPlaceholder: __('Search'),
          noRefSelected: __('No available branches'),
          noResults: __('No available branches'),
        }"
      />
      <div v-if="!defaultBranch" class="gl-text-red-500 gl-mt-3">
        {{
          s__(
            'OnDemandScans|You must create a repository within your project to run an on-demand scan.',
          )
        }}
      </div>
    </gl-form-group>

    <dast-profiles-selector
      :full-path="projectPath"
      :site-profile-id="selectedSiteProfileId"
      :scanner-profile-id="selectedScannerProfileId"
      @profiles="updateSelectedProfiles"
      @error="showErrors"
      @hasProfilesConflict="hasProfilesConflict = $event"
    />

    <div class="gl-mt-6 gl-pt-6">
      <gl-button
        type="submit"
        variant="success"
        class="js-no-auto-disable"
        data-testid="on-demand-scan-submit-button"
        :disabled="isSubmitButtonDisabled"
        :loading="loading === $options.saveAndRunScanBtnId"
      >
        {{ s__('OnDemandScans|Save and run scan') }}
      </gl-button>
      <gl-button
        variant="success"
        category="secondary"
        data-testid="on-demand-scan-save-button"
        :disabled="isSaveButtonDisabled"
        :loading="loading === $options.saveScanBtnId"
        @click="onSubmit({ runAfter: false, button: $options.saveScanBtnId })"
      >
        {{ s__('OnDemandScans|Save scan') }}
      </gl-button>
      <gl-button
        data-testid="on-demand-scan-cancel-button"
        :disabled="Boolean(loading)"
        @click="onCancelClicked"
      >
        {{ __('Cancel') }}
      </gl-button>
    </div>
  </gl-form>
</template>
