<script>
import { GlModal, GlAlert } from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { s__, __ } from '~/locale';
/*import createOncallScheduleMutation from '../graphql/mutations/create_oncall_schedule.mutation.graphql';
import updateOncallScheduleMutation from '../graphql/mutations/update_oncall_schedule.mutation.graphql';
import getOncallSchedulesWithRotationsQuery from '../graphql/queries/get_oncall_schedules.query.graphql';
import { updateStoreOnScheduleCreate, updateStoreAfterScheduleEdit } from '../utils/cache_updates';*/
import { isNameFieldValid } from '../utils';
import AddEditEscalationPolicyForm from './add_edit_escalation_policy_form.vue';

export const i18n = {
  cancel: __('Cancel'),
  addEscalationPolicy: s__('EscalationPolicies|Add escalation policy'),
  addErrorMsg: s__('EscalationPolicies|Failed to edit escalation policy'),
};

export default {
  i18n,
  components: {
    GlModal,
    GlAlert,
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
        timezone: true,
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
    isFormValid() {
      return Object.values(this.validationState).every(Boolean);
    },
    editEscalationPolicyVariables() {
      return {
        projectPath: this.projectPath,
        iid: this.escalationPolicy.iid,
        name: this.form.name,
        description: this.form.description,
      };
    },
    errorMsg() {
      return this.error || (this.isEditMode ? i18n.editErrorMsg : i18n.addErrorMsg);
    },
    title() {
      return this.isEditMode ? i18n.editEscalationPolicy : i18n.addEscalationPolicy;
    },
  },
  methods: {
    // createEscalationPolicy() {
    //   this.loading = true;
    //   const { projectPath } = this;
    //
    //   this.$apollo
    //     .mutate({
    //       mutation: createOncallEscalationPolicyMutation,
    //       variables: {
    //         oncallEscalationPolicyCreateInput: {
    //           projectPath,
    //           ...this.form,
    //           timezone: this.form.timezone.identifier,
    //         },
    //       },
    //       update(store, { data }) {
    //         updateStoreOnEscalationPolicyCreate(store, getOncallEscalationPolicysWithRotationsQuery, data, {
    //           projectPath,
    //         });
    //       },
    //     })
    //     .then(
    //       ({
    //         data: {
    //           oncallEscalationPolicyCreate: {
    //             errors: [error],
    //           },
    //         },
    //       }) => {
    //         if (error) {
    //           throw error;
    //         }
    //         this.$refs.addUpdateEscalationPolicyModal.hide();
    //         this.$emit('EscalationPolicyCreated');
    //         this.clearEscalationPolicyForm();
    //       },
    //     )
    //     .catch((error) => {
    //       this.error = error;
    //     })
    //     .finally(() => {
    //       this.loading = false;
    //     });
    // },
    hideErrorAlert() {
      this.error = '';
    },
    updateEscalationPolicyForm({ type, value }) {
      this.form[type] = value;
      this.validateForm(type);
    },
    validateForm(key) {
      if (key === 'name') {
        this.validationState.name = isNameFieldValid(this.form.name);
      } else if (key === 'timezone') {
        this.validationState.timezone = !isEmpty(this.form.timezone);
      }
    },
    clearEscalationPolicyForm() {
      this.form.name = '';
      this.form.description = '';
      this.form.timezone = {};
    },
  },
};
</script>

<template>
  <gl-modal
    ref="addUpdateEscalationPolicyModal"
    :modal-id="modalId"
    size="sm"
    :title="title"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary.prevent="isEditMode ? editEscalationPolicy() : createEscalationPolicy()"
  >
    <gl-alert v-if="error" variant="danger" class="gl-mt-n3 gl-mb-3" @dismiss="hideErrorAlert">
      {{ errorMsg }}
    </gl-alert>
    <add-edit-escalation-policy-form
      :validation-state="validationState"
      :form="form"
      :escalation-policy="escalationPolicy"
      @update-escalation-policy-form="updateEscalationPolicyForm"
    />
  </gl-modal>
</template>
