<script>
import { isEmpty } from 'lodash';
import { GlModal, GlAlert } from '@gitlab/ui';
import { s__, __ } from '~/locale';
import createOncallScheduleMutation from '../graphql/mutations/create_oncall_schedule.mutation.graphql';
import AddEditScheduleForm from './add_edit_schedule_form.vue';

export const i18n = {
  cancel: __('Cancel'),
  addSchedule: s__('OnCallSchedules|Add schedule'),
  errorMsg: s__('OnCallSchedules|Failed to add schedule'),
};

export default {
  i18n,
  inject: ['projectPath', 'timezones'],
  components: {
    GlModal,
    GlAlert,
    AddEditScheduleForm,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      loading: false,
      form: {
        name: '',
        description: '',
        timezone: '',
      },
      error: null,
    };
  },
  computed: {
    actionsProps() {
      return {
        primary: {
          text: i18n.addSchedule,
          attributes: [
            { variant: 'info' },
            { loading: this.loading },
            { disabled: this.isFormInvalid },
          ],
        },
        cancel: {
          text: i18n.cancel,
        },
      };
    },
    isNameInvalid() {
      return !this.form.name.length;
    },
    isTimezoneInvalid() {
      return isEmpty(this.form.timezone);
    },
    isFormInvalid() {
      return this.isNameInvalid || this.isTimezoneInvalid;
    },
  },
  methods: {
    createSchedule() {
      this.loading = true;

      this.$apollo
        .mutate({
          mutation: createOncallScheduleMutation,
          variables: {
            oncallScheduleCreateInput: {
              projectPath: this.projectPath,
              ...this.form,
              timezone: this.form.timezone.identifier,
            },
          },
        })
        .then(({ data: { oncallScheduleCreate: { errors: [error] } } }) => {
          if (error) {
            throw error;
          }
          this.$refs.createScheduleModal.hide();
        })
        .catch(error => {
          this.error = error;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    hideErrorAlert() {
      this.error = null;
    },
    updateScheduleForm({ type, value }) {
      this.form[type] = value;
    },
  },
};
</script>

<template>
  <gl-modal
    ref="createScheduleModal"
    :modal-id="modalId"
    size="sm"
    :title="$options.i18n.addSchedule"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary.prevent="createSchedule"
  >
    <gl-alert v-if="error" variant="danger" class="gl-mt-n3 gl-mb-3" @dismiss="hideErrorAlert">
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <add-edit-schedule-form
      :is-name-invalid="isNameInvalid"
      :is-timezone-invalid="isTimezoneInvalid"
      :form="form"
      @update-schedule-form="updateScheduleForm"
    />
  </gl-modal>
</template>
