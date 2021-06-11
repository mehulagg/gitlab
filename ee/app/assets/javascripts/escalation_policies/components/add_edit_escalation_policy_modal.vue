<script>
import { GlModal, GlAlert } from '@gitlab/ui';
import { set } from 'lodash';
import { s__, __ } from '~/locale';
import { addEscalationPolicyModalId } from '../constants';
import { updateStoreOnEscalationPolicyCreate } from '../graphql/cache_updates';
import createEscalationPolicyMutation from '../graphql/mutations/create_escalation_policy.mutation.graphql';
import getEscalationPoliciesQuery from '../graphql/queries/get_escalation_policies.query.graphql';
import { isNameFieldValid, getRulesValidationState } from '../utils';
import AddEditEscalationPolicyForm from './add_edit_escalation_policy_form.vue';

export const i18n = {
  cancel: __('Cancel'),
  addEscalationPolicy: s__('EscalationPolicies|Add escalation policy'),
  editEscalationPolicy: s__('EscalationPolicies|Edit escalation policy'),
};

export default {
  i18n,
  addEscalationPolicyModalId,
  components: {
    GlModal,
    GlAlert,
    AddEditEscalationPolicyForm,
  },
  inject: ['projectPath'],
  props: {
    escalationPolicy: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      loading: false,
      form: {
        name: this.escalationPolicy.name,
        description: this.escalationPolicy.description,
        rules: [],
      },
      validationState: {
        name: null,
        rules: [],
      },
      error: null,
    };
  },
  computed: {
    actionsProps() {
      return {
        primary: {
          text: i18n.addEscalationPolicy,
          attributes: [
            { variant: 'info' },
            { loading: this.loading },
            { disabled: !this.isFormValid },
          ],
        },
        cancel: {
          text: i18n.cancel,
        },
      };
    },
    isFormValid() {
      return (
        this.validationState.name &&
        this.validationState.rules.every(
          ({ isTimeValid, isScheduleValid }) => isTimeValid && isScheduleValid,
        )
      );
    },
  },
  methods: {
    updateForm({ field, value }) {
      set(this.form, field, value);
      this.validateForm(field);
    },
    createEscalationPolicy() {
      this.loading = true;
      const { projectPath } = this;
      this.$apollo
        .mutate({
          mutation: createEscalationPolicyMutation,
          variables: {
            input: {
              projectPath,
              ...this.getRequestParams(),
            },
          },
          update(store, { data }) {
            updateStoreOnEscalationPolicyCreate(store, getEscalationPoliciesQuery, data, {
              projectPath,
            });
          },
        })
        .then(
          ({
            data: {
              escalationPolicyCreate: {
                errors: [error],
              },
            },
          }) => {
            if (error) {
              throw error;
            }
            this.$refs.addUpdateEscalationPolicyModal.hide();
            this.$emit('policyCreated');
            this.resetForm();
          },
        )
        .catch((error) => {
          this.error = error;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    getRequestParams() {
      const rules = this.form.rules.map(({ status, elapsedTimeSeconds, oncallScheduleIid }) => ({
        status,
        elapsedTimeSeconds,
        oncallScheduleIid,
      }));

      return { ...this.form, rules };
    },
    validateForm(field) {
      if (field === 'name') {
        this.validationState.name = isNameFieldValid(this.form.name);
      }
      if (field === 'rules') {
        this.validationState.rules = getRulesValidationState(this.form.rules);
      }
    },
    hideErrorAlert() {
      this.error = null;
    },
    resetForm() {
      this.form = {
        name: '',
        description: '',
        rules: [],
      };
      this.validationState = {
        name: null,
        rules: [],
      };
      this.hideErrorAlert();
    },
  },
};
</script>

<template>
  <gl-modal
    ref="addUpdateEscalationPolicyModal"
    class="escalation-policy-modal"
    :modal-id="$options.addEscalationPolicyModalId"
    :title="$options.i18n.addEscalationPolicy"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary.prevent="createEscalationPolicy"
    @canceled="resetForm"
    @close="resetForm"
  >
    <gl-alert v-if="error" variant="danger" class="gl-mt-n3 gl-mb-3" @dismiss="hideErrorAlert">
      {{ error }}
    </gl-alert>
    <add-edit-escalation-policy-form
      :validation-state="validationState"
      :form="form"
      @update-escalation-policy-form="updateForm"
    />
  </gl-modal>
</template>
