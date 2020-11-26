<script>
import { produce } from 'immer';
import { uniqueId } from 'lodash';
import {
  GlAlert,
  GlButton,
  GlIcon,
  GlModal,
  GlSkeletonLoader,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import DastSiteValidationModal from 'ee/security_configuration/dast_site_validation/components/dast_site_validation_modal.vue';
import {
  DAST_SITE_VALIDATION_STATUS,
  DAST_SITE_VALIDATION_STATUS_PROPS,
} from 'ee/security_configuration/dast_site_validation/constants';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';
import dastSiteValidationsQuery from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_validation.query.graphql';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

const { PENDING, FAILED, INPROGRESS } = DAST_SITE_VALIDATION_STATUS;

export default {
  components: {
    GlAlert,
    GlButton,
    GlIcon,
    GlModal,
    GlSkeletonLoader,
    GlTable,
    DastSiteValidationModal,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  apollo: {
    validation: {
      // Since this is only to showcase how we could write to the cache after a query, I've reused the existing
      // dast_site_validation query here, but we'd need to adapt this to work with the newer dast_site_validations query
      query: dastSiteValidationsQuery,
      manual: true,
      variables() {
        return {
          fullPath: this.fullPath,
          targetUrl: 'http://gdk.test/',
        };
      },
      pollInterval: 1000, // todo: make it a constant
      skip() {
        return false;
      },
      result() {
        const store = this.$apolloProvider.defaultClient;
        // We need to construct the body of the query that we want to modify
        // This makes things potentially complex regarding pagination as I'm not sure if
        // we'll be able to change the whole dataset in one pass, or wheter this forces us
        // to modify each page individually...
        // Note that I hardcoded `first: 10` for now.
        const queryBody = {
          query: dastSiteProfilesQuery,
          variables: {
            fullPath: this.fullPath,
            first: 10,
          },
        };
        // Retrieve the current data from the cache
        const sourceData = store.readQuery(queryBody);
        // Modify the data as needed, we'll only be chaning all site profiles' names for now
        const data = produce(sourceData, draftState => {
          // eslint-disable-next-line no-param-reassign
          draftState.project.siteProfiles.edges = draftState.project.siteProfiles.edges.map(
            edge => {
              return {
                ...edge,
                node: {
                  ...edge.node,
                  profileName: 'optimistic update',
                },
              };
            },
          );
        });
        // Finally, write back to the cache
        store.writeQuery({ ...queryBody, data });
      },
    },
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    profiles: {
      type: Array,
      required: true,
    },
    fields: {
      type: Array,
      required: true,
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
    errorDetails: {
      type: Array,
      required: false,
      default: () => [],
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    profilesPerPage: {
      type: Number,
      required: true,
    },
    hasMoreProfilesToLoad: {
      type: Boolean,
      required: false,
      default: false,
    },
    fullPath: {
      type: String,
      required: true,
    },
    profileType: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      toBeDeletedProfileId: null,
      validatingProfile: null,
      uniqueNonValidatedTargets: [],
    };
  },
  statuses: DAST_SITE_VALIDATION_STATUS_PROPS,
  computed: {
    hasError() {
      return this.errorMessage !== '';
    },
    hasErrorDetails() {
      return this.errorDetails.length > 0;
    },
    hasProfiles() {
      return this.profiles.length > 0;
    },
    isLoadingInitialProfiles() {
      return this.isLoading && !this.hasProfiles;
    },
    shouldShowTable() {
      return this.isLoadingInitialProfiles || this.hasProfiles || this.hasError;
    },
    modalId() {
      return `dast-profiles-list-${uniqueId()}`;
    },
    tableFields() {
      const defaultClasses = ['gl-word-break-all'];
      const dataFields = this.fields.map(key => ({ key, class: defaultClasses }));
      const staticFields = [{ key: 'actions' }];

      return [...dataFields, ...staticFields];
    },
  },
  // Move this to use this.$watch() based on profile type
  watch: {
    profiles: {
      immediate: true,
      handler: 'validateTargets',
    },
  },
  methods: {
    handleDelete() {
      this.$emit('delete-profile', this.toBeDeletedProfileId);
    },
    prepareProfileDeletion(profileId) {
      this.toBeDeletedProfileId = profileId;
      this.$refs[this.modalId].show();
    },
    handleCancel() {
      this.toBeDeletedProfileId = null;
    },
    shouldShowValidationBtn(status) {
      return (
        this.glFeatures.securityOnDemandScansSiteValidation &&
        (status === PENDING || status === FAILED)
      );
    },
    shouldShowValidationStatus(status) {
      return this.glFeatures.securityOnDemandScansSiteValidation && status !== PENDING;
    },
    showValidationModal() {
      this.$refs['dast-site-validation-modal'].show();
    },
    setValidatingProfile(profile) {
      this.validatingProfile = profile;
      this.$nextTick(() => {
        this.showValidationModal();
      });
    },
    validateTargets() {
      if (this.profileType !== 'siteProfiles') {
        return;
      }
      const nonValidatedTargets = this.profiles
        .filter(({ validationStatus }) => validationStatus === PENDING)
        .map(({ normalizedTargetUrl }) => normalizedTargetUrl);

      this.uniqueNonValidatedTargets = Array.from(new Set(nonValidatedTargets));
    },
  },
};
</script>
<template>
  <section>
    <div v-if="shouldShowTable">
      <gl-table
        :aria-label="s__('DastProfiles|Site Profiles')"
        :busy="isLoadingInitialProfiles"
        :fields="tableFields"
        :items="profiles"
        stacked="md"
        thead-class="gl-display-none"
      >
        <template v-if="hasError" #top-row>
          <td :colspan="tableFields.length">
            <gl-alert class="gl-my-4" variant="danger" :dismissible="false">
              {{ errorMessage }}
              <ul
                v-if="hasErrorDetails"
                :aria-label="__('DastProfiles|Error Details')"
                class="gl-p-0 gl-m-0"
              >
                <li v-for="errorDetail in errorDetails" :key="errorDetail">{{ errorDetail }}</li>
              </ul>
            </gl-alert>
          </td>
        </template>

        <template #cell(profileName)="{ value }">
          <strong>{{ value }}</strong>
        </template>

        <template #cell(validationStatus)="{ value }">
          <template v-if="shouldShowValidationStatus(value)">
            <span :class="$options.statuses[value].cssClass">
              {{ $options.statuses[value].label }}
            </span>
            <gl-icon
              v-gl-tooltip
              name="question-o"
              class="gl-vertical-align-text-bottom gl-text-gray-300 gl-ml-2"
              :title="$options.statuses[value].tooltipText"
            />
          </template>
        </template>

        <template #cell(actions)="{ item }">
          <div class="gl-text-right">
            <gl-button
              v-if="shouldShowValidationBtn(item.validationStatus)"
              variant="info"
              category="secondary"
              size="small"
              @click="setValidatingProfile(item)"
              >{{ s__('DastSiteValidation|Validate target site') }}</gl-button
            >

            <gl-button v-if="item.editPath" :href="item.editPath" class="gl-mx-5" size="small">{{
              __('Edit')
            }}</gl-button>

            <gl-button
              v-gl-tooltip.hover.focus
              icon="remove"
              variant="danger"
              category="secondary"
              size="small"
              class="gl-mr-3"
              :title="s__('DastProfiles|Delete profile')"
              @click="prepareProfileDeletion(item.id)"
            />
          </div>
        </template>

        <template #table-busy>
          <div v-for="i in profilesPerPage" :key="i" data-testid="loadingIndicator">
            <gl-skeleton-loader :width="1248" :height="52">
              <rect x="0" y="16" width="300" height="20" rx="4" />
              <rect x="380" y="16" width="300" height="20" rx="4" />
              <rect x="770" y="16" width="300" height="20" rx="4" />
              <rect x="1140" y="11" width="50" height="30" rx="4" />
            </gl-skeleton-loader>
          </div>
        </template>
      </gl-table>

      <p v-if="hasMoreProfilesToLoad" class="gl-display-flex gl-justify-content-center">
        <gl-button
          data-testid="loadMore"
          :loading="isLoading && !hasError"
          @click="$emit('load-more-profiles')"
        >
          {{ __('Load more') }}
        </gl-button>
      </p>
    </div>

    <p v-else class="gl-my-4">
      {{ s__('DastProfiles|No profiles created yet') }}
    </p>

    <gl-modal
      :ref="modalId"
      :modal-id="modalId"
      :title="s__('DastProfiles|Are you sure you want to delete this profile?')"
      :ok-title="__('Delete')"
      :static="true"
      :lazy="true"
      ok-variant="danger"
      body-class="gl-display-none"
      @ok="handleDelete"
      @cancel="handleCancel"
    />

    <dast-site-validation-modal
      v-if="validatingProfile"
      ref="dast-site-validation-modal"
      :full-path="fullPath"
      :target-url="validatingProfile.targetUrl"
    />
  </section>
</template>
