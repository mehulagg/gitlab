<script>
import { isEmpty } from 'lodash';
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
      error: null,
      form: {
        name: this.schedule.name,
        description: this.schedule.description,
        timezone: this.timezones.find(({ identifier }) => this.schedule.timezone === identifier),
      },
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
    isNameInvalid() {
      return !this.form.name.length;
    },
    isTimezoneInvalid() {
      return isEmpty(this.form.timezone);
    },
    isFormInvalid() {
      return this.isNameInvalid || this.isTimezoneInvalid;
    },
    editScheduleVariables() {
      return {
        projectPath: this.projectPath,
        iid: this.schedule.iid,
        name: this.form.name,
        description: this.form.description,
        timezone: this.form.timezone.identifier,
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
          variables: this.editScheduleVariables,
          update(store, { data }) {
            updateStoreAfterScheduleEdit(store, getOncallSchedulesQuery, data, { projectPath });
          },
        })
        .then(({ data: { oncallScheduleUpdate: { errors: [error] } } }) => {
          if (error) {
            throw error;
          }
          this.$refs.updateScheduleModal.hide();
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
    ref="updateScheduleModal"
    modal-id="updateScheduleModal"
    size="sm"
    :data-testid="`update-schedule-modal-${schedule.iid}`"
    :title="$options.i18n.editSchedule"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary.prevent="editSchedule"
  >
    <gl-alert v-if="error" variant="danger" class="gl-mt-n3 gl-mb-3" @dismiss="hideErrorAlert">
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <add-edit-schedule-form
      :is-name-invalid="isNameInvalid"
      :is-timezone-invalid="isTimezoneInvalid"
      :form="form"
      :schedule="schedule"
      @update-schedule-form="updateScheduleForm"
    />
  </gl-modal>
</template>
