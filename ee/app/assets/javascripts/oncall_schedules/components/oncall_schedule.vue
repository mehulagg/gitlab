<script>
import { GlSprintf, GlCard, GlButtonGroup, GlButton, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import ScheduleTimelineSection from './schedule/components/schedule_timeline_section.vue';
import DestroyScheduleModal from './destroy_schedule_modal.vue';
import { getTimeframeForWeeksView } from './schedule/utils';
import { PRESET_TYPES, PRESET_DEFAULTS } from './schedule/constants';
import { getFormattedTimezone } from '../utils';

export const i18n = {
  title: s__('OnCallSchedules|On-call schedule'),
  scheduleForTz: s__('OnCallSchedules|On-call schedule for the %{tzShort}'),
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
    DestroyScheduleModal,
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
      return getTimeframeForWeeksView(PRESET_TYPES.WEEKS, PRESET_DEFAULTS.WEEKS.TIMEFRAME_LENGTH);
    },
  },
};
</script>

<template>
  <div>
    <h2 ref="title">{{ $options.i18n.title }}</h2>
    <gl-card>
      <template #header>
        <div class="gl-display-flex gl-justify-content-space-between">
          <span class="gl-font-weight-bold gl-font-lg">{{ schedule.name }}</span>
          <gl-button-group>
            <gl-button icon="pencil" />
            <gl-button v-gl-modal.destroyScheduleModal icon="remove" />
          </gl-button-group>
        </div>
      </template>

      <div class="gl-text-gray-500 gl-mb-5">
        <gl-sprintf :message="$options.i18n.scheduleForTz">
          <template #tzShort>
            <span>{{ schedule.timezone }}</span>
          </template>
        </gl-sprintf>
        | <span>{{ tzLong }}</span>
      </div>

      <div class="schedule-shell js-schedule-shell">
        <schedule-timeline-section :preset-type="$options.presetType" :timeframe="timeframe" />
      </div>
    </gl-card>
    <destroy-schedule-modal :schedule="schedule" />
  </div>
</template>
