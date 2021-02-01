<script>
import { visitUrl } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import * as Sentry from '~/sentry/wrapper';
import SharedForm from './shared_form.vue';

import createComplianceFrameworkMutation from '../graphql/queries/create_compliance_framework.mutation.graphql';

export default {
  components: {
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
    async onSubmit(formData) {
      try {
        const { data } = await this.$apollo.mutate({
          mutation: createComplianceFrameworkMutation,
          variables: {
            input: {
              namespacePath: this.groupPath,
              params: {
                name: formData.name,
                description: formData.description,
                color: formData.color,
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
        this.setError(e, this.$options.i18n.saveError);
      }
    },
  },
  i18n: {
    saveError: s__(
      'ComplianceFrameworks|Unable to save this compliance framework. Please try again',
    ),
  },
};
</script>
<template>
  <shared-form
    :group-edit-path="groupEditPath"
    :loading="isLoading"
    :render-form="!isLoading"
    :error="errorMessage"
    @submit="onSubmit"
  />
</template>
