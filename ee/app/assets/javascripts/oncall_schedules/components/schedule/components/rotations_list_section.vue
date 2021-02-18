<script>
import { GlButtonGroup, GlButton, GlTooltipDirective, GlModalDirective } from '@gitlab/ui';
import DeleteRotationModal from 'ee/oncall_schedules/components/rotations/components/delete_rotation_modal.vue';
import ScheduleShiftWrapper from 'ee/oncall_schedules/components/schedule/components/shifts/components/schedule_shift_wrapper.vue';
import {
  editRotationModalId,
  deleteRotationModalId,
  PRESET_TYPES,
  TIMELINE_CELL_WIDTH,
} from 'ee/oncall_schedules/constants';
import { s__ } from '~/locale';
import CurrentDayIndicator from './current_day_indicator.vue';

export const i18n = {
  editRotationLabel: s__('OnCallSchedules|Edit rotation'),
  deleteRotationLabel: s__('OnCallSchedules|Delete rotation'),
};

export default {
  i18n,
  editRotationModalId,
  deleteRotationModalId,
  components: {
    GlButton,
    GlButtonGroup,
    CurrentDayIndicator,
    DeleteRotationModal,
    ScheduleShiftWrapper,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    rotations: {
      type: Array,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    scheduleIid: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      rotationToUpdate: {},
    };
  },
  computed: {
    presetIsDay() {
      return this.presetType === PRESET_TYPES.DAYS;
    },
    timeframeToDraw() {
      if (this.presetIsDay) {
        return [this.timeframe[0]];
      }

      return this.timeframe;
    },
    timelineStyles() {
      const length = this.presetIsDay ? 1 : 2;

      return {
        width: `calc((${100}% - ${TIMELINE_CELL_WIDTH}px) / ${length})`,
      };
    },
  },
  methods: {
    setRotationToUpdate(rotation) {
      this.rotationToUpdate = rotation;
    },
    cellShouldHideOverflow(index) {
      return index + 1 === this.timeframe.length || this.presetIsDay;
    },
  },
};
</script>

<template>
  <div class="list-section">
    <div
      v-for="rotation in rotations"
      :key="rotation.id"
      class="list-item list-item-empty clearfix"
    >
      <span
        class="details-cell gl-display-flex gl-justify-content-space-between gl-align-items-center gl-pl-3"
      >
        <span class="gl-str-truncated">{{ rotation.name }}</span>
        <gl-button-group class="gl-px-2">
          <gl-button
            v-gl-modal="$options.editRotationModalId"
            v-gl-tooltip
            category="tertiary"
            :title="$options.i18n.editRotationLabel"
            icon="pencil"
            :aria-label="$options.i18n.editRotationLabel"
            :disabled="true"
          />
          <gl-button
            v-gl-modal="$options.deleteRotationModalId"
            v-gl-tooltip
            category="tertiary"
            :title="$options.i18n.deleteRotationLabel"
            icon="remove"
            :aria-label="$options.i18n.deleteRotationLabel"
            @click="setRotationToUpdate(rotation)"
          />
        </gl-button-group>
      </span>
      <span
        v-for="(timeframeItem, index) in timeframeToDraw"
        :key="index"
        class="timeline-cell gl-border-b-solid gl-border-b-gray-100 gl-border-b-1"
        :class="{ 'gl-overflow-hidden': cellShouldHideOverflow(index) }"
        :style="timelineStyles"
        data-testid="timelineCell"
      >
        <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
        <schedule-shift-wrapper
          v-if="rotation.shifts"
          :preset-type="presetType"
          :timeframe-item="timeframeItem"
          :timeframe="timeframe"
          :rotation="rotation"
        />
      </span>
    </div>
    <delete-rotation-modal
      :rotation="rotationToUpdate"
      :schedule-iid="scheduleIid"
      :modal-id="$options.deleteRotationModalId"
      @set-rotation-to-update="setRotationToUpdate"
    />
  </div>
</template>
