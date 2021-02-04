<script>
import { visitUrl } from '~/lib/utils/url_utility';
import * as Sentry from '~/sentry/wrapper';
import createComplianceFrameworkMutation from '../graphql/queries/create_compliance_framework.mutation.graphql';
import { SAVE_ERROR } from '../constants';
import { initialiseFormData } from '../utils';
import SharedForm from './shared_form.vue';
import FormStatus from './form_status.vue';

export default {
  components: {
    FormStatus,
    SharedForm,
  },
  inject: ['groupEditPath', 'groupPath'],
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
      :name.sync="formData.name"
      :description.sync="formData.description"
      :color.sync="formData.color"
      @submit="onSubmit"
    />
  </form-status>
</template>
