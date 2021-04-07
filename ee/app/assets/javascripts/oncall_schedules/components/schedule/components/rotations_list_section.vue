<script>
import {
  GlButtonGroup,
  GlButton,
  GlLoadingIcon,
  GlTooltipDirective,
  GlModalDirective,
} from '@gitlab/ui';
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
  addRotationLabel: s__('OnCallSchedules|Currently no rotation.'),
};

export default {
  i18n,
  editRotationModalId,
  deleteRotationModalId,
  components: {
    GlButton,
    GlButtonGroup,
    GlLoadingIcon,
    CurrentDayIndicator,
    DeleteRotationModal,
    ScheduleShiftWrapper,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    presetType: {
      type: String,
      required: true,
    },
    rotations: {
      type: Array,
      required: true,
    },
    scheduleIid: {
      type: String,
      required: true,
    },
    timeframe: {
      type: Array,
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
      this.$emit('set-rotation-to-update', rotation);
    },
    cellShouldHideOverflow(index) {
      return index + 1 === this.timeframe.length || this.presetIsDay;
    },
    timeframeItemUniqueKey(timeframeItem) {
      return timeframeItem.valueOf();
    },
  },
};
</script>

<template>
  <div class="list-section">
    <gl-loading-icon v-if="loading" />
    <div v-else-if="rotations.length === 0 && !loading" class="gl-clearfix">
      <span
        class="details-cell gl-display-flex gl-justify-content-space-between gl-align-items-center gl-pl-3"
      >
        <span class="gl-text-truncate">{{ $options.i18n.addRotationLabel }}</span>
      </span>
      <span
        v-for="(timeframeItem, index) in timeframeToDraw"
        :key="index"
        class="timeline-cell gl-border-b-solid gl-border-b-gray-100 gl-border-b-1"
        :style="timelineStyles"
        data-testid="empty-timeline-cell"
      >
        <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
      </span>
    </div>
    <div v-else>
      <div v-for="rotation in rotations" :key="rotation.id" class="gl-clearfix">
        <span
          class="details-cell gl-display-flex gl-justify-content-space-between gl-align-items-center gl-pl-3"
        >
          <span
            v-gl-tooltip="{ boundary: 'viewport', title: rotation.name }"
            class="gl-text-truncate"
            :aria-label="rotation.name"
            :data-testid="`rotation-name-${rotation.id}`"
            >{{ rotation.name }}</span
          >
          <gl-button-group class="gl-px-2">
            <gl-button
              v-gl-modal="$options.editRotationModalId"
              v-gl-tooltip
              category="tertiary"
              :title="$options.i18n.editRotationLabel"
              icon="pencil"
              :aria-label="$options.i18n.editRotationLabel"
              @click="setRotationToUpdate(rotation)"
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
          :key="timeframeItemUniqueKey(timeframeItem)"
          class="timeline-cell gl-border-b-solid gl-border-b-gray-100 gl-border-b-1"
          :class="{ 'gl-overflow-hidden': cellShouldHideOverflow(index) }"
          :style="timelineStyles"
          data-testid="timeline-cell"
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
    </div>
    <delete-rotation-modal
      :rotation="rotationToUpdate"
      :schedule-iid="scheduleIid"
      :modal-id="$options.deleteRotationModalId"
      @set-rotation-to-update="setRotationToUpdate"
    />
  </div>
</template>
