<script>
import * as Sentry from '@sentry/browser';
import { visitUrl } from '~/lib/utils/url_utility';
import { SAVE_ERROR } from '../constants';
import createComplianceFrameworkMutation from '../graphql/queries/create_compliance_framework.mutation.graphql';
import { initialiseFormData } from '../utils';
import FormStatus from './form_status.vue';
import SharedForm from './shared_form.vue';

export default {
  components: {
    FormStatus,
    SharedForm,
  },
  props: {
    groupEditPath: {
      type: String,
      required: true,
    },
    groupPath: {
      type: String,
      required: true,
    },
    pipelineConfigurationFullPathEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      errorMessage: '',
      formData: initialiseFormData(),
      saving: false,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.loading || this.saving;
    },
  },
  methods: {
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
          mutation: createComplianceFrameworkMutation,
          variables: {
            input: {
              namespacePath: this.groupPath,
              params: {
                name,
                description,
                pipelineConfigurationFullPath,
                color,
              },
            },
          },
        });

        const [error] = data?.createComplianceFramework?.errors || [];

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
      :group-edit-path="groupEditPath"
      :pipeline-configuration-full-path-enabled="pipelineConfigurationFullPathEnabled"
      :name.sync="formData.name"
      :description.sync="formData.description"
      :pipeline-configuration-full-path.sync="formData.pipelineConfigurationFullPath"
      :color.sync="formData.color"
      @submit="onSubmit"
    />
  </form-status>
</template>
