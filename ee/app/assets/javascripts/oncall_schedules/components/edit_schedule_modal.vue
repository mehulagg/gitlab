<script>
import { GlModal, GlAlert } from '@gitlab/ui';
import { s__, __ } from '~/locale';
import updateOncallScheduleMutation from '../graphql/mutations/update_oncall_schedule.mutation.graphql';
import getOncallSchedulesQuery from '../graphql/queries/get_oncall_schedules.query.graphql';
import { updateStoreAfterScheduleEdit } from '../utils/cache_updates';
import AddEditScheduleForm from './add_edit_schedule_form.vue';

export const i18n = {
  cancel: __('Cancel'),
  editSchedule: s__('OnCallSchedules|Edit schedule'),
  errorMsg: s__('OnCallSchedules|Failed to edit schedule'),
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
    schedule: {
      type: Object,
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
          text: i18n.editSchedule,
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
    editSchedule() {
      const { projectPath } = this;
      this.loading = true;

      this.$apollo
        .mutate({
          mutation: updateOncallScheduleMutation,
          variables: {
            oncallScheduleEditInput: {
              projectPath: this.projectPath,
              ...this.form,
              timezone: this.form.timezone.identifier,
            },
          },
          update(store, { data }) {
            updateStoreAfterScheduleEdit(store, getOncallSchedulesQuery, data, { projectPath });
          },
        })
        .then(({ data: { oncallScheduleEdit: { errors: [error] } } }) => {
          if (error) {
            throw error;
          }
          this.$refs.updateScheduleModal.hide();
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
    ref="updateScheduleModal"
    modal-id="updateScheduleModal"
    size="sm"
    :title="$options.i18n.editSchedule"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary.prevent="editSchedule"
  >
    <gl-alert
      v-if="showErrorAlert"
      variant="danger"
      class="gl-mt-n3 gl-mb-3"
      @dismiss="hideErrorAlert"
    >
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <add-edit-schedule-form :schedule="schedule" @update-schedule-form="updateScheduleForm" />
  </gl-modal>
</template>
