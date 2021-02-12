<script>
import { visitUrl } from '~/lib/utils/url_utility';
import * as Sentry from '~/sentry/wrapper';
import { convertToGraphQLId } from '~/graphql_shared/utils';

import getComplianceFrameworkQuery from '../graphql/queries/get_compliance_framework.query.graphql';
import updateComplianceFrameworkMutation from '../graphql/queries/update_compliance_framework.mutation.graphql';
import { FETCH_ERROR, SAVE_ERROR } from '../constants';
import { initialiseFormData } from '../utils';
import SharedForm from './shared_form.vue';
import FormStatus from './form_status.vue';

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
      initErrorMessage: '',
      saveErrorMessage: '',
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
        this.setInitError(error, FETCH_ERROR);
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
    showForm() {
      return (
        Object.values(this.formData).filter((d) => d !== null).length > 0 && !this.initErrorMessage
      );
    },
    errorMessage() {
      return this.initErrorMessage || this.saveErrorMessage;
    },
  },
  methods: {
    extractComplianceFramework(data) {
      const complianceFrameworks = data.namespace?.complianceFrameworks?.nodes || [];

      if (!complianceFrameworks.length) {
        this.setInitError(new Error(FETCH_ERROR), FETCH_ERROR);

        return initialiseFormData();
      }

      const { name, description, color } = complianceFrameworks[0];

      return {
        name,
        description,
        color,
      };
    },
    setInitError(error, userFriendlyText) {
      this.initErrorMessage = userFriendlyText;
      Sentry.captureException(error);
    },
    setSavingError(error, userFriendlyText) {
      this.saveErrorMessage = userFriendlyText;
      Sentry.captureException(error);
    },
    async onSubmit() {
      this.saving = true;
      this.saveErrorMessage = '';

      try {
        const { name, description, color } = this.formData;
        const { data } = await this.$apollo.mutate({
          mutation: updateComplianceFrameworkMutation,
          variables: {
            input: {
              id: this.graphqlId,
              params: {
                name,
                description,
                color,
              },
            },
          },
        });

        const [error] = data?.updateComplianceFramework?.errors || [];

        if (error) {
          this.setSavingError(new Error(error), error);
        } else {
          this.saving = false;
          visitUrl(this.groupEditPath);
        }
      } catch (e) {
        this.setSavingError(e, SAVE_ERROR);
      }

      this.saving = false;
    },
  },
};
</script>
<template>
  <form-status :loading="isLoading" :error="errorMessage">
    <shared-form
      v-if="showForm"
      :group-edit-path="groupEditPath"
      :name.sync="formData.name"
      :description.sync="formData.description"
      :color.sync="formData.color"
      @submit="onSubmit"
    />
  </form-status>
</template>
