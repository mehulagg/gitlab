<script>
import { visitUrl } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import * as Sentry from '~/sentry/wrapper';
import { convertToGraphQLId, getIdFromGraphQLId } from '~/graphql_shared/utils';
import SharedForm from './shared_form.vue';

import getComplianceFrameworkQuery from '../graphql/queries/get_compliance_framework.query.graphql';
import updateComplianceFrameworkMutation from '../graphql/queries/update_compliance_framework.mutation.graphql';

const FRAMEWORK_GRAPHQL_ID_TYPE = 'ComplianceManagement::Framework';

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
    id: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      complianceFramework: {},
      error: '',
    };
  },
  apollo: {
    complianceFramework: {
      query: getComplianceFrameworkQuery,
      variables() {
        return {
          fullPath: this.groupPath,
          complianceFramework: convertToGraphQLId(FRAMEWORK_GRAPHQL_ID_TYPE, this.id),
        };
      },
      update(data) {
        const nodes = data.namespace?.complianceFrameworks?.nodes || [];

        if (!nodes.length) {
          this.setError(
            new Error(this.$options.i18n.unknownFrameworkError),
            this.$options.i18n.fetchError,
          );

          return {};
        }

        const { id, name, description, color } = nodes[0];

        return {
          id,
          name,
          description,
          color,
          parsedId: getIdFromGraphQLId(nodes[0].id),
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
  },
  methods: {
    setError(error, userFriendlyText) {
      this.error = userFriendlyText;
      Sentry.captureException(error);
    },
    async onSubmit(complianceFramework) {
      try {
        const { data } = await this.$apollo.mutate({
          mutation: updateComplianceFrameworkMutation,
          variables: {
            input: {
              id: this.complianceFramework.id,
              params: {
                name: complianceFramework.name,
                description: complianceFramework.description,
                color: complianceFramework.color,
              },
            },
          },
        });

        const errors = data?.updateComplianceFramework?.errors || [];

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
    unknownFrameworkError: s__(
      'ComplianceFrameworks|Unknown compliance framework given. Please try a different framework or refresh the page',
    ),
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
    :error="error"
    :compliance-framework="complianceFramework"
    @submit="onSubmit"
  />
</template>
