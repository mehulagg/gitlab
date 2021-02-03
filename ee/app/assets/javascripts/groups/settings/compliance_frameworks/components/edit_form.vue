<script>
import { visitUrl } from '~/lib/utils/url_utility';
import * as Sentry from '~/sentry/wrapper';
import { convertToGraphQLId } from '~/graphql_shared/utils';

import getComplianceFrameworkQuery from '../graphql/queries/get_compliance_framework.query.graphql';
import updateComplianceFrameworkMutation from '../graphql/queries/update_compliance_framework.mutation.graphql';
import SharedForm from './shared_form.vue';
import FormStatus from './form_status.vue';
import { initialiseFormData, FETCH_ERROR, SAVE_ERROR } from '../constants';

export default {
  components: {
    FormStatus,
    SharedForm,
  },
  props: {
    graphqlFieldName: {
      type: String,
      required: true,
    },
    groupEditPath: {
      type: String,
      required: true,
    },
    groupPath: {
      type: String,
      required: true,
    },
    id: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      errorMessage: '',
      formData: initialiseFormData(),
      saving: false,
    };
  },
  apollo: {
    namespace: {
      query: getComplianceFrameworkQuery,
      variables() {
        return {
          fullPath: this.groupPath,
          complianceFramework: this.graphqlId,
        };
      },
      result({ data }) {
        this.formData = this.extractComplianceFramework(data);
      },
      error(error) {
        this.setError(error, FETCH_ERROR);
      },
    },
  },
  computed: {
    graphqlId() {
      return convertToGraphQLId(this.graphqlFieldName, this.id);
    },
    isLoading() {
      return this.$apollo.loading || this.saving;
    },
    hasFormData() {
      return Boolean(this.formData?.name);
    },
  },
  methods: {
    extractComplianceFramework(data) {
      const complianceFrameworks = data.namespace?.complianceFrameworks?.nodes || [];

      if (!complianceFrameworks.length) {
        this.setError(new Error(FETCH_ERROR), FETCH_ERROR);

        return initialiseFormData();
      }

      const { name, description, pipelineConfigurationFullPath, color } = complianceFrameworks[0];

      return {
        name,
        description,
        pipelineConfigurationFullPath,
        color,
      };
    },
    setError(error, userFriendlyText) {
      this.errorMessage = userFriendlyText;
      Sentry.captureException(error);
    },
    async onSubmit() {
      this.saving = true;
      this.errorMessage = '';

      try {
        const { name, description, pipelineConfigurationFullPath, color } = this.formData;
        const { data } = await this.$apollo.mutate({
          mutation: updateComplianceFrameworkMutation,
          variables: {
            input: {
              id: this.graphqlId,
              params: {
                name,
                description,
                pipelineConfigurationFullPath,
                color,
              },
            },
          },
        });

        const [error] = data?.updateComplianceFramework?.errors || [];

        if (error) {
          this.setError(new Error(error), error);
        } else {
          this.saving = false;
          visitUrl(this.groupEditPath);
        }
      } catch (e) {
        this.setError(e, SAVE_ERROR);
      }

      this.saving = false;
    },
  },
};
</script>
<template>
  <form-status :loading="isLoading" :error="errorMessage">
    <shared-form
      v-if="hasFormData"
      :group-edit-path="groupEditPath"
      :name.sync="formData.name"
      :description.sync="formData.description"
      :pipeline-configuration-full-path.sync="formData.pipelineConfigurationFullPath"
      :color.sync="formData.color"
      @submit="onSubmit"
    />
  </form-status>
</template>
