<script>
import { GlSprintf, GlCard, GlButtonGroup, GlButton, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import ScheduleTimelineSection from './schedule/components/schedule_timeline_section.vue';
import DeleteScheduleModal from './delete_schedule_modal.vue';
import EditScheduleModal from './edit_schedule_modal.vue';
import { getTimeframeForWeeksView } from './schedule/utils';
import { PRESET_TYPES } from './schedule/constants';
import { getFormattedTimezone } from '../utils';

export const i18n = {
  title: s__('OnCallSchedules|On-call schedule'),
  scheduleForTz: s__('OnCallSchedules|On-call schedule for the %{tzShort}'),
  updateScheduleLabel: s__('OnCallSchedules|Edit schedule'),
  destroyScheduleLabel: s__('OnCallSchedules|Delete schedule'),
};

export default {
  i18n,
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
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    schedule: {
      type: Object,
      required: true,
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
    <h2>{{ $options.i18n.title }}</h2>
    <gl-card>
      <template #header>
        <div class="gl-display-flex gl-justify-content-space-between gl-m-0">
          <span class="gl-font-weight-bold gl-font-lg">{{ schedule.name }}</span>
          <gl-button-group>
            <gl-button
              v-gl-modal.updateScheduleModal
              icon="pencil"
              :aria-label="$options.i18n.updateScheduleLabel"
            />
            <gl-button
              v-gl-modal.deleteScheduleModal
              icon="remove"
              :aria-label="$options.i18n.destroyScheduleLabel"
            />
          </gl-button-group>
        </div>
      </template>

      <p class="gl-text-gray-500 gl-mb-5">
        <gl-sprintf :message="$options.i18n.scheduleForTz">
          <template #tzShort>{{ schedule.timezone }}</template>
        </gl-sprintf>
        | {{ tzLong }}
      </p>

      <div class="schedule-shell">
        <schedule-timeline-section :preset-type="$options.presetType" :timeframe="timeframe" />
      </div>
    </gl-card>
    <delete-schedule-modal :schedule="schedule" />
    <edit-schedule-modal :schedule="schedule" />
  </div>
</template>
