<script>
import { GlEmptyState, GlButton, GlLoadingIcon, GlModalDirective } from '@gitlab/ui';
import createFlash, { FLASH_TYPES } from '~/flash';
import * as Sentry from '~/sentry/wrapper';
import AddScheduleModal from './add_schedule_modal.vue';
import OncallSchedule from './oncall_schedule.vue';
import { s__ } from '~/locale';
import getOncallSchedulesQuery from '../graphql/get_oncall_schedules.query.graphql';
import destroyOncallScheduleMutation from '../graphql/mutations/destroy_oncall_schedule.mutation.graphql';
import { updateStoreAfterScheduleDelete } from '../utils/cache_updates';
import { fetchPolicies } from '~/lib/graphql';

const addScheduleModalId = 'addScheduleModal';

export const i18n = {
  emptyState: {
    title: s__('OnCallSchedules|Create on-call schedules  in GitLab'),
    description: s__('OnCallSchedules|Route alerts directly to specific members of your team'),
    button: s__('OnCallSchedules|Add a schedule'),
    scheduleRemoved: s__('OnCallSchedules|Schedule as sucessfully removed.'),
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
    OncallSchedule,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  data() {
    return {
      errored: false,
      isUpdating: false,
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
        this.errored = true;
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.schedule.loading;
    },
  },
  methods: {
    deleteSchedule(id) {
      const { projectPath } = this;

      this.isUpdating = true;
      this.$apollo
        .mutate({
          mutation: destroyOncallScheduleMutation,
          variables: {
            id,
          },
          update(store, { data }) {
            updateStoreAfterScheduleDelete(store, getOncallSchedulesQuery, data, { projectPath });
          },
        })
        .then(({ data: { oncallScheduleDestroy } = {} } = {}) => {
          const error = oncallScheduleDestroy?.errors[0];
          if (error) {
            return createFlash({ message: error });
          }
          return createFlash({
            message: this.$options.i18n.scheduleRemoved,
            type: FLASH_TYPES.SUCCESS,
          });
        })
        .catch(error => {
          this.errored = true;
          Sentry.captureException(error);
        })
        .finally(() => {
          this.isUpdating = false;
        });
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-3" />
    <oncall-schedule v-else-if="schedule" :schedule="schedule" @delete-schedule="deleteSchedule" />
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
    <add-schedule-modal :modal-id="$options.addScheduleModalId" />
  </div>
</template>
