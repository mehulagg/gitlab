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
      error: '',
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.loading;
    },
  },
  methods: {
    setError(error, userFriendlyText) {
      this.error = userFriendlyText;
      Sentry.captureException(error);
    },
    async onSubmit(complianceFramework) {
      try {
        const { data } = await this.$apollo.mutate({
          mutation: createComplianceFrameworkMutation,
          variables: {
            input: {
              namespacePath: this.groupPath,
              params: {
                name: complianceFramework.name,
                description: complianceFramework.description,
                color: complianceFramework.color,
              },
            },
          },
        });

        const errors = data?.createComplianceFramework?.errors || [];

        if (errors.length) {
          this.setError(new Error(errors[0]), errors[0]);
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
    :error="error"
    @submit="onSubmit"
  />
</template>
