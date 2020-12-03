<script>
import { GlEmptyState, GlButton, GlModalDirective } from '@gitlab/ui';
import AddScheduleModal from './add_schedule_modal.vue';
import AddRotationModal from './rotations/add_rotation_modal.vue';
import { s__ } from '~/locale';

const addScheduleModalId = 'addScheduleModal';

export const i18n = {
  emptyState: {
    title: s__('OnCallSchedules|Create on-call schedules  in GitLab'),
    description: s__('OnCallSchedules|Route alerts directly to specific members of your team'),
    button: s__('OnCallSchedules|Add a schedule'),
  },
};

export default {
  i18n,
  addScheduleModalId,
  inject: ['emptyOncallSchedulesSvgPath'],
  components: {
    GlEmptyState,
    GlButton,
    AddScheduleModal,
    AddRotationModal,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  methods: {},
};
</script>

<template>
  <div>
    <gl-empty-state
      :title="$options.i18n.emptyState.title"
      :description="$options.i18n.emptyState.description"
      :svg-path="emptyOncallSchedulesSvgPath"
    >
      <template #actions>
        <gl-button v-gl-modal="$options.addScheduleModalId" variant="info">
          {{ $options.i18n.emptyState.button }}
        </gl-button>
        <gl-button v-gl-modal="'create-schedule-rotation-modal'" variant="danger">
          {{ $options.i18n.emptyState.button }}
        </gl-button>
      </template>
    </gl-empty-state>
    <add-schedule-modal :modal-id="$options.addScheduleModalId" />
    <add-rotation-modal />
  </div>
</template>
