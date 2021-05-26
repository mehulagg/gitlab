<script>
import { GlModal, GlAlert } from '@gitlab/ui';
import { set } from 'lodash';
import { s__, __ } from '~/locale';
import { addEscalationPolicyModalId } from '../constants';
import createEscalationPolicyMutation from '../graphql/mutations/create_escalation_policy.mutation.graphql';
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
        name: true,
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
      return this.validationState.name && this.validationState.rules.every(Boolean);
    },
    serializedData() {
      const rules = this.form.rules.map(({ status, elapsedTimeSeconds, oncallScheduleIid }) => ({
        status,
        elapsedTimeSeconds,
        oncallScheduleIid,
      }));
      return { ...this.form, rules };
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
              ...this.serializedData,
            },
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
            this.clearForm();
          },
        )
        .catch((error) => {
          this.error = error;
        })
        .finally(() => {
          this.loading = false;
        });
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
    clearForm() {
      this.form = {
        name: '',
        description: '',
        rules: [],
      };
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
    @cancel="clearForm"
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
