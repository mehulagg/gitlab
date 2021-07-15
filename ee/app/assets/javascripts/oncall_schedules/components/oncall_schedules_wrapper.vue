<script>
import {
  GlAlert,
  GlButton,
  GlEmptyState,
  GlLoadingIcon,
  GlLink,
  GlModalDirective,
  GlTooltipDirective,
  GlSprintf,
} from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { s__ } from '~/locale';
import { escalationPolicyUrl } from '../constants';
import getOncallSchedulesWithRotationsQuery from '../graphql/queries/get_oncall_schedules.query.graphql';
import AddScheduleModal from './add_edit_schedule_modal.vue';
import OncallSchedule from './oncall_schedule.vue';

export const addScheduleModalId = 'addScheduleModal';

export const i18n = {
  title: s__('OnCallSchedules|On-call schedules'),
  add: {
    button: s__('OnCallSchedules|Add a schedule'),
    tooltip: s__('OnCallSchedules|Add an additional schedule to your project'),
  },
  emptyState: {
    title: s__('OnCallSchedules|Create on-call schedules  in GitLab'),
    description: s__('OnCallSchedules|Route alerts directly to specific members of your team'),
  },
  successNotification: {
    title: s__('OnCallSchedules|Try adding a rotation'),
    description: s__(
      'OnCallSchedules|Your schedule has been successfully created. To add individual users to this schedule, use the add a rotation button. To create an escalation policy that defines which schedule is used when, visit the %{linkStart}escalation policy%{linkEnd} page.',
    ),
  },
};

export default {
  i18n,
  addScheduleModalId,
  escalationPolicyUrl,
  components: {
    GlAlert,
    GlButton,
    GlEmptyState,
    GlLoadingIcon,
    GlLink,
    GlSprintf,
    AddScheduleModal,
    OncallSchedule,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  inject: ['emptyOncallSchedulesSvgPath', 'projectPath'],
  data() {
    return {
      schedules: [],
      showSuccessNotification: false,
    };
  },
  apollo: {
    schedules: {
      query: getOncallSchedulesWithRotationsQuery,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update(data) {
        return data.project?.incidentManagementOncallSchedules?.nodes ?? [];
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.schedules.loading;
    },
    hasSchedules() {
      return this.schedules.length;
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-3" />

    <template v-else-if="hasSchedules">
      <div class="gl-display-flex gl-justify-content-space-between gl-align-items-center">
        <h2>{{ $options.i18n.title }}</h2>
        <gl-button
          v-gl-modal="$options.addScheduleModalId"
          v-gl-tooltip.left.viewport.hover
          :title="$options.i18n.add.tooltip"
          :aria-label="$options.i18n.add.tooltip"
          category="secondary"
          variant="confirm"
          class="gl-mt-5"
          data-testid="add-additional-schedules-button"
        >
          {{ $options.i18n.add.button }}
        </gl-button>
      </div>
      <gl-alert
        v-if="showSuccessNotification"
        variant="tip"
        :title="$options.i18n.successNotification.title"
        class="gl-my-3"
        @dismiss="showSuccessNotification = false"
      >
        <gl-sprintf :message="$options.i18n.successNotification.description">
          <template #link="{ content }">
            <gl-link :href="$options.escalationPolicyUrl" target="_blank">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </gl-alert>
      <oncall-schedule
        v-for="(schedule, scheduleIndex) in schedules"
        :key="schedule.iid"
        :schedule="schedule"
        :schedule-index="scheduleIndex"
      />
    </template>

    <gl-empty-state
      v-else
      :title="$options.i18n.emptyState.title"
      :description="$options.i18n.emptyState.description"
      :svg-path="emptyOncallSchedulesSvgPath"
    >
      <template #actions>
        <gl-button v-gl-modal="$options.addScheduleModalId" variant="confirm">
          {{ $options.i18n.add.button }}
        </gl-button>
      </template>
    </gl-empty-state>
    <add-schedule-modal
      :modal-id="$options.addScheduleModalId"
      @scheduleCreated="showSuccessNotification = true"
    />
  </div>
</template>
