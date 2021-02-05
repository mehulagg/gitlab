<script>
import {
  GlSprintf,
  GlCard,
  GlButtonGroup,
  GlButton,
  GlModalDirective,
  GlTooltipDirective,
} from '@gitlab/ui';
import { capitalize } from 'lodash';
import { s__, __ } from '~/locale';
import * as Sentry from '~/sentry/wrapper';
import {
  formatDate,
  nWeeksBefore,
  nWeeksAfter,
  nDaysBefore,
  nDaysAfter,
} from '~/lib/utils/datetime_utility';
import ScheduleTimelineSection from './schedule/components/schedule_timeline_section.vue';
import DeleteScheduleModal from './delete_schedule_modal.vue';
import EditScheduleModal from './add_edit_schedule_modal.vue';
import AddEditRotationModal from './rotations/components/add_edit_rotation_modal.vue';
import RotationsListSection from './schedule/components/rotations_list_section.vue';
import { getTimeframeForWeeksView } from './schedule/utils';
import { addRotationModalId, editRotationModalId, PRESET_TYPES } from '../constants';
import getShiftsForRotations from '../graphql/queries/get_oncall_schedules_with_rotations_shifts.query.graphql';

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
  inject: ['projectPath', 'timezones'],
  props: {
    schedule: {
      type: Object,
      required: true,
    },
  },
  apollo: {
    rotations: {
      query: getShiftsForRotations,
      variables() {
        const startsAt = this.timeframeStartDate;
        const endsAt = new Date(nWeeksAfter(startsAt, 2));

        return {
          projectPath: this.projectPath,
          startsAt,
          endsAt,
        };
      },
      update(data) {
        const nodes = data.project?.incidentManagementOncallSchedules?.nodes ?? [];
        const schedule = nodes.length ? nodes[nodes.length - 1] : null;
        return schedule?.rotations;
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  data() {
    return {
      presetType: this.$options.PRESET_TYPES.WEEKS,
      timeframeStartDate: new Date(),
      rotations: this.schedule.rotations,
    };
  },
  computed: {
    offset() {
      const selectedTz = this.timezones.find((tz) => tz.identifier === this.schedule.timezone);
      return __(`(UTC ${selectedTz.formatted_offset})`);
    },
    timeframe() {
      return getTimeframeForWeeksView(this.timeframeStartDate);
    },
    scheduleRange() {
      switch (this.presetType) {
        case PRESET_TYPES.DAYS:
          return formatDate(this.timeframe[0], 'mmmm d, yyyy');
        case PRESET_TYPES.WEEKS: {
          const firstDayOfTheLastWeek = this.timeframe[this.timeframe.length - 1];
          const firstDayOfTheNextTimeframe = nWeeksAfter(firstDayOfTheLastWeek, 1);
          const lastDayOfTimeframe = nDaysBefore(new Date(firstDayOfTheNextTimeframe), 1);

          return `${formatDate(this.timeframe[0], 'mmmm d')} - ${formatDate(
            lastDayOfTimeframe,
            'mmmm d, yyyy',
          )}`;
        }
        default:
          return '';
      }
    },
    isLoading() {
      return this.$apollo.queries.rotations.loading;
    },
  },
  methods: {
    switchPresetType(type) {
      this.presetType = type;
      this.timeframeStartDate = new Date();
    },
    formatPresetType(type) {
      return capitalize(type);
    },
    updateToViewPreviousTimeframe() {
      switch (this.presetType) {
        case PRESET_TYPES.DAYS:
          this.timeframeStartDate = new Date(nDaysBefore(this.timeframeStartDate, 1));
          break;
        case PRESET_TYPES.WEEKS:
          this.timeframeStartDate = new Date(nWeeksBefore(this.timeframeStartDate, 2));
          break;
        default:
          break;
      }
    },
    updateToViewNextTimeframe() {
      switch (this.presetType) {
        case PRESET_TYPES.DAYS:
          this.timeframeStartDate = new Date(nDaysAfter(this.timeframeStartDate, 1));
          break;
        case PRESET_TYPES.WEEKS:
          this.timeframeStartDate = new Date(nWeeksAfter(this.timeframeStartDate, 2));
          break;
        default:
          break;
      }
    },
    fetchRotationShifts() {
      this.$apollo.queries.rotations.refetch();
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
        <gl-button-group data-testid="shift-preset-change">
          <gl-button
            v-for="type in $options.PRESET_TYPES"
            :key="type"
            :selected="type === presetType"
            :title="formatPresetType(type)"
            @click="switchPresetType(type)"
          >
            {{ formatPresetType(type) }}
          </gl-button>
        </gl-button-group>
      </p>
      <div class="gl-w-full gl-display-flex gl-align-items-center gl-pb-3">
        <gl-button-group>
          <gl-button
            icon="chevron-left"
            :disabled="isLoading"
            @click="updateToViewPreviousTimeframe"
          />
          <gl-button
            icon="chevron-right"
            :disabled="isLoading"
            @click="updateToViewNextTimeframe"
          />
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
            :rotations="rotations.nodes"
            :timeframe="timeframe"
            :schedule-iid="schedule.iid"
            :loading="isLoading"
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
    <add-edit-rotation-modal
      :schedule="schedule"
      :modal-id="$options.addRotationModalId"
      @fetchRotationShifts="fetchRotationShifts"
    />
    <add-edit-rotation-modal
      :schedule="schedule"
      :modal-id="$options.editRotationModalId"
      is-edit-mode
    />
  </div>
</template>
