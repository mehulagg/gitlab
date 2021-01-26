<script>
import { GlAlert, GlButton, GlEmptyState, GlLoadingIcon, GlModalDirective } from '@gitlab/ui';
import mockRotations from '../../../../../spec/frontend/oncall_schedule/mocks/mock_rotation.json';
import * as Sentry from '~/sentry/wrapper';
import AddScheduleModal from './add_edit_schedule_modal.vue';
import OncallSchedule from './oncall_schedule.vue';
import { s__ } from '~/locale';
import getOncallSchedulesQuery from '../graphql/queries/get_oncall_schedules.query.graphql';
import { fetchPolicies } from '~/lib/graphql';

export const addScheduleModalId = 'addScheduleModal';

export const i18n = {
  title: s__('OnCallSchedules|On-call schedule'),
  emptyState: {
    title: s__('OnCallSchedules|Create on-call schedules  in GitLab'),
    description: s__('OnCallSchedules|Route alerts directly to specific members of your team'),
    button: s__('OnCallSchedules|Add a schedule'),
  },
  successNotification: {
    title: s__('OnCallSchedules|Try adding a rotation'),
    description: s__(
      'OnCallSchedules|Your schedule has been successfully created and all alerts from this project will now be routed to this schedule. Currently, only one schedule can be created per project. More coming soon! To add individual users to this schedule, use the add a rotation button.',
    ),
  },
};

export default {
  mockRotations,
  i18n,
  addScheduleModalId,
  components: {
    GlAlert,
    GlButton,
    GlEmptyState,
    GlLoadingIcon,
    AddScheduleModal,
    OncallSchedule,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: ['emptyOncallSchedulesSvgPath', 'projectPath'],
  data() {
    return {
      schedule: {},
      showSuccessNotification: false,
    };
  },
  apollo: {
    schedule: {
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      query: getOncallSchedulesQuery,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update(data) {
        const nodes = data.project?.incidentManagementOncallSchedules?.nodes ?? [];
        return nodes.length ? nodes[nodes.length - 1] : null;
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.schedule.loading;
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-3" />

    <template v-else-if="schedule">
      <h2>{{ $options.i18n.title }}</h2>
      <gl-alert
        v-if="showSuccessNotification"
        variant="tip"
        :title="$options.i18n.successNotification.title"
        class="gl-my-3"
        @dismiss="showSuccessNotification = false"
      >
        {{ $options.i18n.successNotification.description }}
      </gl-alert>
      <oncall-schedule :schedule="schedule" :rotations="$options.mockRotations" />
    </template>

    <gl-empty-state
      v-else
      :title="$options.i18n.emptyState.title"
      :description="$options.i18n.emptyState.description"
      :svg-path="emptyOncallSchedulesSvgPath"
    >
      <template #actions>
        <gl-button v-gl-modal="$options.addScheduleModalId" variant="info">
          {{ $options.i18n.emptyState.button }}
        </gl-button>
      </template>
    </gl-empty-state>
    <add-schedule-modal
      :modal-id="$options.addScheduleModalId"
      @scheduleCreated="showSuccessNotification = true"
    />
  </div>
</template>
