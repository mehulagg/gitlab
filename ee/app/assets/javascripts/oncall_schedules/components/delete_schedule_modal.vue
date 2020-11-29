<script>
import { GlSprintf, GlModal } from '@gitlab/ui';
import { s__, __ } from '~/locale';

export const i18n = {
  deleteSchedule: s__('OnCallSchedules|Delete schedule'),
};

export default {
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
      this.$emit('delete-schedule', { id: this.schedule.id });
    },
  },
};
</script>

<template>
    <gl-modal
      modal-id="deleteSchedule"
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
