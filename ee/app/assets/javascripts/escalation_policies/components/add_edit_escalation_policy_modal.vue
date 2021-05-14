<script>
import { GlModal } from '@gitlab/ui';
import { set } from 'lodash';
import { s__, __ } from '~/locale';
import createEscalationPolicyMutation from '../graphql/mutations/create_escalation_policy.mutation.graphql';
import { isNameFieldValid } from '../utils';
import AddEditEscalationPolicyForm from './add_edit_escalation_policy_form.vue';

export const i18n = {
  cancel: __('Cancel'),
  addEscalationPolicy: s__('EscalationPolicies|Add escalation policy'),
  editEscalationPolicy: s__('EscalationPolicies|Edit escalation policy'),
};

export default {
  i18n,
  components: {
    GlModal,
    AddEditEscalationPolicyForm,
  },
  inject: ['projectPath'],
  props: {
    modalId: {
      type: String,
      required: true,
    },
    escalationPolicy: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    isEditMode: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      loading: false,
      form: {
        name: this.escalationPolicy.name,
        description: this.escalationPolicy.description,
      },
      error: '',
      validationState: {
        name: true,
        rules: true,
      },
    };
  },
  computed: {
    actionsProps() {
      return {
        primary: {
          text: this.title,
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
    canFormSubmit() {
      return isNameFieldValid(this.form.name);
    },
    isFormValid() {
      return Object.values(this.validationState).every(Boolean) && this.canFormSubmit;
    },
    errorMsg() {
      return this.error || (this.isEditMode ? i18n.editErrorMsg : i18n.addErrorMsg);
    },
    title() {
      return this.isEditMode ? i18n.editEscalationPolicy : i18n.addEscalationPolicy;
    },
  },
  methods: {
    createEscalationPolicy() {
      this.loading = true;
      const { projectPath } = this;
      this.$apollo
        .mutate({
          mutation: createEscalationPolicyMutation,
          variables: {
            input: {
              projectPath,
              ...this.form,
            },
          },
          /*    update(store, { data }) {
            updateStoreOnScheduleCreate(store, getOncallSchedulesWithRotationsQuery, data, {
              projectPath,
            });
          }, */
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
            // this.clearScheduleForm();
          },
        )
        .catch((error) => {
          this.error = error;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    // TODO: will be implemented in scope of https://gitlab.com/gitlab-org/gitlab/-/issues/268362
    editEscalationPolicy() {},
    updateForm({ type, value }) {
      set(this.form, type, value);
      this.validateForm(type);
    },
    validateForm(key) {
      if (key === 'name') {
        this.validationState.name = isNameFieldValid(this.form.name);
      }
    },
  },
};
</script>

<template>
  <gl-modal
    ref="addUpdateEscalationPolicyModal"
    class="escalation-policy-modal"
    :modal-id="modalId"
    :title="title"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary.prevent="isEditMode ? editEscalationPolicy() : createEscalationPolicy()"
  >
    <add-edit-escalation-policy-form
      :validation-state="validationState"
      :form="form"
      @update-escalation-policy-form="updateForm"
    />
  </gl-modal>
</template>
