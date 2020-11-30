<script>
import { GlSprintf, GlModal } from '@gitlab/ui';
import destroyOncallScheduleMutation from '../graphql/mutations/destroy_oncall_schedule.mutation.graphql';
import getOncallSchedulesQuery from '../graphql/queries/get_oncall_schedules.query.graphql';
import { updateStoreAfterScheduleDelete } from '../utils/cache_updates';
import { s__, __ } from '~/locale';

export const i18n = {
  deleteSchedule: s__('OnCallSchedules|Delete schedule'),
};

export default {
  i18n,
  components: {
    GlSprintf,
    GlModal,
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
    };
  },
  computed: {
    primaryProps() {
      return {
        text: this.$options.i18n.deleteSchedule,
        attributes: [{ category: 'primary' }, { variant: 'danger' }],
      };
    },
    cancelProps() {
      return {
        text: __('Cancel'),
      };
    },
  },
  methods: {
    deleteSchedule() {
      const { projectPath } = this;

      this.loading = true;
      this.$apollo
        .mutate({
          mutation: destroyOncallScheduleMutation,
          variables: {
            id: this.schedule.id,
          },
          update(store, { data }) {
            updateStoreAfterScheduleDelete(store, getOncallSchedulesQuery, data, { projectPath });
          },
        })
        .then(({ data: { oncallScheduleDestroy } = {} } = {}) => {
          const error = oncallScheduleDestroy?.errors[0];
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
  },
};
</script>

<template>
  <gl-modal
    ref="deleteSchedule"
    modal-id="deleteScheduleModal"
    :title="$options.i18n.deleteSchedule"
    :action-primary="primaryProps"
    :action-cancel="cancelProps"
    @primary="deleteSchedule"
  >
    <gl-sprintf
      :message="
        s__(
          'OnCallSchedules|Are you sure you want to delete the %{deleteSchedule} schedule. This action cannot be undone.',
        )
      "
    >
      <template #deleteSchedule>{{ schedule.name }}</template>
    </gl-sprintf>
  </gl-modal>
</template>
