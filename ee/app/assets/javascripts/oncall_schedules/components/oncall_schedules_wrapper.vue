<script>
import { GlEmptyState, GlButton, GlLoadingIcon, GlModalDirective } from '@gitlab/ui';
import * as Sentry from '~/sentry/wrapper';
import AddScheduleModal from './add_schedule_modal.vue';
import AddRotationModal from './rotations/add_rotation_modal.vue';
import OncallSchedule from './oncall_schedule.vue';
import { s__ } from '~/locale';
import getOncallSchedulesQuery from '../graphql/queries/get_oncall_schedules.query.graphql';
import { fetchPolicies } from '~/lib/graphql';

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
  inject: ['emptyOncallSchedulesSvgPath', 'projectPath'],
  components: {
    GlEmptyState,
    GlButton,
    GlLoadingIcon,
    AddScheduleModal,
    AddRotationModal,
    OncallSchedule,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  data() {
    return {
      schedule: {},
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
        return data?.project?.incidentManagementOncallSchedules?.nodes?.[0] ?? null;
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
    <oncall-schedule v-else-if="schedule" :schedule="schedule" />
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
        <gl-button v-gl-modal="'create-schedule-rotation-modal'" variant="danger">
          {{ $options.i18n.emptyState.button }}
        </gl-button>
      </template>
    </gl-empty-state>
    <add-schedule-modal :modal-id="$options.addScheduleModalId" />
    <add-rotation-modal />
  </div>
</template>
