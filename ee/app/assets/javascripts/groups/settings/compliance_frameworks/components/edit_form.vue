<script>
import { visitUrl } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import * as Sentry from '~/sentry/wrapper';
import { convertToGraphQLId } from '~/graphql_shared/utils';

import getComplianceFrameworkQuery from '../graphql/queries/get_compliance_framework.query.graphql';
import updateComplianceFrameworkMutation from '../graphql/queries/update_compliance_framework.mutation.graphql';
import SharedForm from './shared_form.vue';

export default {
  components: {
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
      complianceFramework: {},
      errorMessage: '',
    };
  },
  apollo: {
    complianceFramework: {
      query: getComplianceFrameworkQuery,
      variables() {
        return {
          fullPath: this.groupPath,
          complianceFramework: convertToGraphQLId(this.graphqlFieldName, this.id),
        };
      },
      update(data) {
        const complianceFrameworks = data.namespace?.complianceFrameworks?.nodes || [];

        if (!complianceFrameworks.length) {
          this.setError(new Error(this.$options.i18n.fetchError), this.$options.i18n.fetchError);

          return {};
        }

        const { id, name, description, color } = complianceFrameworks[0];

        return {
          id,
          name,
          description,
          color,
        };
      },
      error(error) {
        this.setError(error, this.$options.i18n.fetchError);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.loading;
    },
    isFormReady() {
      return Object.keys(this.complianceFramework).length > 0 && !this.isLoading;
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
          mutation: updateComplianceFrameworkMutation,
          variables: {
            input: {
              id: this.complianceFramework.id,
              params: {
                name: formData.name,
                description: formData.description,
                color: formData.color,
              },
            },
          },
        });

        const [error] = data?.updateComplianceFramework?.errors || [];

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
    fetchError: s__(
      'ComplianceFrameworks|Error fetching compliance frameworks data. Please refresh the page',
    ),
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
    :render-form="isFormReady"
    :error="errorMessage"
    :compliance-framework="complianceFramework"
    @submit="onSubmit"
  />
</template>
