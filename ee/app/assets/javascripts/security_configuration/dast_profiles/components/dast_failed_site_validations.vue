<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import DastSiteValidationModal from 'ee/security_configuration/dast_site_validation/components/dast_site_validation_modal.vue';
import { DAST_SITE_VALIDATION_MODAL_ID } from 'ee/security_configuration/dast_site_validation/constants';
import dastSiteValidationRevokeMutation from 'ee/security_configuration/dast_site_validation/graphql/dast_site_validation_revoke.mutation.graphql';
import dastFailedSiteValidationsQuery from '../graphql/dast_failed_site_validations.query.graphql';

export default {
  name: 'DastFailedSiteValidations',
  dastSiteValidationModalId: DAST_SITE_VALIDATION_MODAL_ID,
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
    DastSiteValidationModal,
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      failedValidations: [],
      validateTargetUrl: null,
    };
  },
  apollo: {
    dastFailedSiteValidations: {
      query: dastFailedSiteValidationsQuery,
      manual: true,
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      result({
        data: {
          project: {
            validations: { nodes },
          },
        },
      }) {
        this.failedValidations = nodes.map((node) => ({
          ...node,
          url: new URL(node.normalizedTargetUrl).href,
        }));
      },
    },
  },
  methods: {
    retryValidation({ url }) {
      this.validateTargetUrl = url;
      this.$nextTick(() => {
        this.$refs[DAST_SITE_VALIDATION_MODAL_ID].show();
      });
    },
    revokeValidation({ normalizedTargetUrl }) {
      this.$apollo.mutate({
        mutation: dastSiteValidationRevokeMutation,
        variables: {
          fullPath: this.fullPath,
          normalizedTargetUrl,
        },
      });
      this.failedValidations = this.failedValidations.filter(
        (failedValidation) => failedValidation.normalizedTargetUrl !== normalizedTargetUrl,
      );
    },
  },
};
</script>

<template>
  <div v-if="failedValidations.length">
    <gl-alert
      v-for="failedValidation in failedValidations"
      :key="failedValidation.url"
      variant="danger"
      class="gl-mt-3"
      @dismiss="revokeValidation(failedValidation)"
    >
      <gl-sprintf
        :message="
          s__(
            'DastSiteValidation|Validation failed for %{url}. %{retryButtonStart}Retry validation%{retryButtonEnd}.',
          )
        "
      >
        <template #url>{{ failedValidation.url }}</template>
        <template #retryButton="{ content }"
          ><gl-link href="#" role="button" @click="retryValidation(failedValidation)">{{
            content
          }}</gl-link></template
        >
      </gl-sprintf>
    </gl-alert>

    <dast-site-validation-modal
      v-if="validateTargetUrl"
      :ref="$options.dastSiteValidationModalId"
      :full-path="fullPath"
      :target-url="validateTargetUrl"
      @hidden="validateTargetUrl = null"
    />
  </div>
</template>
