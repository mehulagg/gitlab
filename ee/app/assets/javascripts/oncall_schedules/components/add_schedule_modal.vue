<script>
import { GlModal, GlAlert } from '@gitlab/ui';
import { s__ } from '~/locale';
import createOncallScheduleMutation from '../graphql/mutations/create_oncall_schedule.mutation.graphql';
import AddEditScheduleForm from './add_edit_schedule_form.vue';

export const i18n = {
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
      showErrorAlert: false,
      error: '',
      form: null,
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
  },
  methods: {
    createSchedule({ form }) {
      this.loading = true;

      this.$apollo
        .mutate({
          mutation: createOncallScheduleMutation,
          variables: {
            oncallScheduleCreateInput: {
              projectPath: this.projectPath,
              ...form,
              timezone: form.timezone.identifier,
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
          this.showErrorAlert = true;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    hideErrorAlert() {
      this.showErrorAlert = false;
    },
    updateScheduleForm({ form }) {
      this.form = form;
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
    <gl-alert
      v-if="showErrorAlert"
      variant="danger"
      class="gl-mt-n3 gl-mb-3"
      @dismiss="hideErrorAlert"
    >
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <add-edit-schedule-form @update-schedule-form="updateScheduleForm" />
  </gl-modal>
</template>
