<script>
import {
  GlSprintf,
  GlCard,
  GlButtonGroup,
  GlButton,
  GlModalDirective,
  GlTooltipDirective,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import ScheduleTimelineSection from './schedule/components/schedule_timeline_section.vue';
import DeleteScheduleModal from './delete_schedule_modal.vue';
import EditScheduleModal from './edit_schedule_modal.vue';
import AddRotationModal from './rotations/components/add_rotation_modal.vue';

import { getTimeframeForWeeksView } from './schedule/utils';
import { PRESET_TYPES } from '../constants';
import { getFormattedTimezone } from '../utils/common_utils';
import RotationsListSection from './schedule/components/rotations_list_section.vue';

export const i18n = {
  scheduleForTz: s__('OnCallSchedules|On-call schedule for the %{tzShort}'),
  editScheduleLabel: s__('OnCallSchedules|Edit schedule'),
  deleteScheduleLabel: s__('OnCallSchedules|Delete schedule'),
  rotationTitle: s__('OnCallSchedules|Rotations'),
  addARotation: s__('OnCallSchedules|Add a rotation'),
};

export const addRotationModalId = 'addRotationModal';
export const editScheduleModalId = 'editScheduleModal';
export const deleteScheduleModalId = 'deleteScheduleModal';

export default {
  i18n,
  addRotationModalId,
  editScheduleModalId,
  deleteScheduleModalId,
  presetType: PRESET_TYPES.WEEKS,
  inject: ['timezones'],
  components: {
    GlSprintf,
    GlCard,
    ScheduleTimelineSection,
    GlButtonGroup,
    GlButton,
    DeleteScheduleModal,
    EditScheduleModal,
    AddRotationModal,
    RotationsListSection,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    schedule: {
      type: Object,
      required: true,
    },
    rotations: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    tzLong() {
      const selectedTz = this.timezones.find(tz => tz.identifier === this.schedule.timezone);
      return getFormattedTimezone(selectedTz);
    },
    timeframe() {
      return getTimeframeForWeeksView();
    },
  },
};
</script>

<template>
  <div>
    <gl-card>
      <template #header>
        <div
          class="gl-display-flex gl-justify-content-space-between gl-m-0"
          data-testid="scheduleHeader"
        >
          <span class="gl-font-weight-bold gl-font-lg">{{ schedule.name }}</span>
          <gl-button-group>
            <gl-button
              v-gl-modal="$options.editScheduleModalId"
              v-gl-tooltip
              :title="$options.i18n.editScheduleLabel"
              icon="pencil"
              :aria-label="$options.i18n.editScheduleLabel"
            />
            <gl-button
              v-gl-modal="$options.deleteScheduleModalId"
              v-gl-tooltip
              :title="$options.i18n.deleteScheduleLabel"
              icon="remove"
              :aria-label="$options.i18n.deleteScheduleLabel"
            />
          </gl-button-group>
        </div>
      </template>
      <p class="gl-text-gray-500 gl-mb-5" data-testid="scheduleBody">
        <gl-sprintf :message="$options.i18n.scheduleForTz">
          <template #tzShort>{{ schedule.timezone }}</template>
        </gl-sprintf>
        | {{ tzLong }}
      </p>

      <gl-card header-class="gl-bg-transparent">
        <template #header>
          <div
            class="gl-display-flex gl-justify-content-space-between"
            data-testid="rotationsHeader"
          >
            <h6 class="gl-m-0">{{ $options.i18n.rotationTitle }}</h6>
            <gl-button v-gl-modal="$options.addRotationModalId" variant="link"
              >{{ $options.i18n.addARotation }}
            </gl-button>
          </div>
        </template>

        <div class="schedule-shell" data-testid="rotationsBody">
          <schedule-timeline-section :preset-type="$options.presetType" :timeframe="timeframe" />
          <rotations-list-section
            :preset-type="$options.presetType"
            :rotations="rotations"
            :timeframe="timeframe"
          />
        </div>
      </gl-card>
    </gl-card>
    <delete-schedule-modal :schedule="schedule" :modal-id="$options.deleteScheduleModalId" />
    <edit-schedule-modal :schedule="schedule" :modal-id="$options.editScheduleModalId" />
    <add-rotation-modal :modal-id="$options.addRotationModalId" />
  </div>
</template>
