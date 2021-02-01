<script>
import { visitUrl } from '~/lib/utils/url_utility';
import * as Sentry from '~/sentry/wrapper';
import createComplianceFrameworkMutation from '../graphql/queries/create_compliance_framework.mutation.graphql';
import SharedForm from './shared_form.vue';
import FormStatus from './form_status.vue';
import { DEFAULT_FORM_DATA, SAVE_ERROR } from '../constants';

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
  },
  data() {
    return {
      errorMessage: '',
      formData: DEFAULT_FORM_DATA,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.loading;
    },
  },
  methods: {
    setError(error, userFriendlyText) {
      this.errorMessage = userFriendlyText;
      Sentry.captureException(error);
    },
    async onSubmit() {
      try {
        const { name, description, color } = this.formData;
        const { data } = await this.$apollo.mutate({
          mutation: createComplianceFrameworkMutation,
          variables: {
            input: {
              namespacePath: this.groupPath,
              params: {
                name,
                description,
                color,
              },
            },
          },
        });

        const [error] = data?.createComplianceFramework?.errors || [];

        if (error) {
          this.setError(new Error(error), error);
        } else {
          visitUrl(this.groupEditPath);
        }
      } catch (e) {
        this.setError(e, SAVE_ERROR);
      }
    },
  },
};
</script>
<template>
  <form-status :loading="isLoading" :error="errorMessage">
    <shared-form
      :group-edit-path="groupEditPath"
      :name.sync="formData.name"
      :description.sync="formData.description"
      :color.sync="formData.color"
      @submit="onSubmit"
    />
  </form-status>
</template>
