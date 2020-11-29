<script>
import {
  GlModal,
  GlAlert,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import editOncallScheduleMutation from '../graphql/mutations/update_oncall_schedule.mutation.graphql';
import AddEditScheduleForm from './add_edit_schedule_form.vue';

export const i18n = {
  cancel: __('Cancel'),
  editSchedule: s__('OnCallSchedules|Add schedule'),
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
      tzSearchTerm: '',
      form: {
        name: '',
        description: '',
        timezone: {},
      },
      showErrorAlert: false,
      error: '',
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
    editSchedule({ form }) {
      this.loading = true;

      this.$apollo
        .mutate({
          mutation: editOncallScheduleMutation,
          variables: {
            oncallScheduleEditInput: {
              projectPath: this.projectPath,
              ...form,
              timezone: this.form.timezone.identifier,
            },
          },
        })
        .then(({ data: { oncallScheduleEdit: { errors: [error] } } }) => {
          if (error) {
            throw error;
          }
          this.$refs.editScheduleModal.hide();
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
  },
};
</script>

<template>
  <gl-modal
    ref="editScheduleModal"
    :modal-id="modalId"
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
    <add-edit-schedule-form @submit-schedule-form="editSchedule" />
  </gl-modal>
</template>
