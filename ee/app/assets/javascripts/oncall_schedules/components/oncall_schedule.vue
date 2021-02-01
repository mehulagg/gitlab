<script>
import {
  GlSprintf,
  GlCard,
  GlButtonGroup,
  GlButton,
  GlDropdown,
  GlDropdownItem,
  GlModalDirective,
  GlTooltipDirective,
} from '@gitlab/ui';
import { capitalize } from 'lodash';
import { formatDate } from '~/lib/utils/datetime_utility';
import { s__, __ } from '~/locale';
import { addRotationModalId, editRotationModalId, PRESET_TYPES } from '../constants';
import ScheduleTimelineSection from './schedule/components/schedule_timeline_section.vue';
import DeleteScheduleModal from './delete_schedule_modal.vue';
import EditScheduleModal from './add_edit_schedule_modal.vue';
import AddEditRotationModal from './rotations/components/add_edit_rotation_modal.vue';
import RotationsListSection from './schedule/components/rotations_list_section.vue';
import { getTimeframeForWeeksView } from './schedule/utils';

export const i18n = {
  scheduleForTz: s__('OnCallSchedules|On-call schedule for the %{timezone}'),
  editScheduleLabel: s__('OnCallSchedules|Edit schedule'),
  deleteScheduleLabel: s__('OnCallSchedules|Delete schedule'),
  rotationTitle: s__('OnCallSchedules|Rotations'),
  addARotation: s__('OnCallSchedules|Add a rotation'),
};
export const editScheduleModalId = 'editScheduleModal';
export const deleteScheduleModalId = 'deleteScheduleModal';

export default {
  i18n,
  addRotationModalId,
  editRotationModalId,
  editScheduleModalId,
  deleteScheduleModalId,
  PRESET_TYPES,
  components: {
    GlButton,
    GlButtonGroup,
    GlCard,
    GlDropdown,
    GlDropdownItem,
    GlSprintf,
    AddEditRotationModal,
    DeleteScheduleModal,
    EditScheduleModal,
    RotationsListSection,
    ScheduleTimelineSection,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  inject: ['timezones'],
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
  data() {
    return {
      presetType: this.$options.PRESET_TYPES.WEEKS,
    };
  },
  computed: {
    offset() {
      const selectedTz = this.timezones.find((tz) => tz.identifier === this.schedule.timezone);
      return __(`(UTC ${selectedTz.formatted_offset})`);
    },
    timeframe() {
      return getTimeframeForWeeksView();
    },
    scheduleRange() {
      const end =
        this.presetType === this.$options.PRESET_TYPES.DAYS
          ? this.timeframe[0]
          : this.timeframe[this.timeframe.length - 1];
      const range = { start: this.timeframe[0], end };

      return `${formatDate(range.start, 'mmmm d')} - ${formatDate(range.end, 'mmmm d, yyyy')}`;
    },
  },
  methods: {
    setPresetType(type) {
      this.presetType = type;
    },
    formatPresetType(type) {
      return capitalize(type);
    },
  },
};
</script>

<template>
  <div>
    <gl-card class="gl-mt-5" header-class="gl-py-3">
      <template #header>
        <div
          class="gl-display-flex gl-justify-content-space-between gl-align-items-center gl-m-0"
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
      <p
        class="gl-text-gray-500 gl-mb-3 gl-display-flex gl-justify-content-space-between gl-align-items-center"
        data-testid="scheduleBody"
      >
        <gl-sprintf :message="$options.i18n.scheduleForTz">
          <template #timezone>{{ schedule.timezone }}</template>
        </gl-sprintf>
        | {{ offset }}
        <gl-dropdown right :text="formatPresetType(presetType)">
          <gl-dropdown-item
            v-for="type in $options.PRESET_TYPES"
            :key="type"
            :is-check-item="true"
            :is-checked="type === presetType"
            @click="setPresetType(type)"
            >{{ formatPresetType(type) }}</gl-dropdown-item
          >
        </gl-dropdown>
      </p>
      <div class="gl-w-full gl-display-flex gl-align-items-center gl-pb-3">
        <gl-button-group>
          <gl-button icon="chevron-left" />
          <gl-button icon="chevron-right" />
        </gl-button-group>
        <p class="gl-ml-3 gl-mb-0">{{ scheduleRange }}</p>
      </div>

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
          <schedule-timeline-section :preset-type="presetType" :timeframe="timeframe" />
          <rotations-list-section
            :preset-type="presetType"
            :rotations="rotations"
            :timeframe="timeframe"
            :schedule-iid="schedule.iid"
          />
        </div>
      </gl-card>
    </gl-card>
    <delete-schedule-modal :schedule="schedule" :modal-id="$options.deleteScheduleModalId" />
    <edit-schedule-modal
      :schedule="schedule"
      :modal-id="$options.editScheduleModalId"
      is-edit-mode
    />
    <add-edit-rotation-modal :schedule="schedule" :modal-id="$options.addRotationModalId" />
    <add-edit-rotation-modal
      :schedule="schedule"
      :modal-id="$options.editRotationModalId"
      is-edit-mode
    />
  </div>
</template>
