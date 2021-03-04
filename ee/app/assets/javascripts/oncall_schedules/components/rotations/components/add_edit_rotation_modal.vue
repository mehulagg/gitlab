<script>
import { GlModal, GlAlert } from '@gitlab/ui';
import { set } from 'lodash';
import { LENGTH_ENUM } from 'ee/oncall_schedules/constants';
import createOncallScheduleRotationMutation from 'ee/oncall_schedules/graphql/mutations/create_oncall_schedule_rotation.mutation.graphql';
import updateOncallScheduleRotationMutation from 'ee/oncall_schedules/graphql/mutations/update_oncall_schedule_rotation.mutation.graphql';
import getOncallSchedulesWithRotationsQuery from 'ee/oncall_schedules/graphql/queries/get_oncall_schedules.query.graphql';
import { updateStoreAfterRotationEdit } from 'ee/oncall_schedules/utils/cache_updates';
import { isNameFieldValid, getParticipantsForSave } from 'ee/oncall_schedules/utils/common_utils';
import createFlash, { FLASH_TYPES } from '~/flash';
import searchProjectMembersQuery from '~/graphql_shared/queries/project_user_members_search.query.graphql';
import { format24HourTimeStringFromInt, formatDate } from '~/lib/utils/datetime_utility';
import { s__, __ } from '~/locale';
import AddEditRotationForm from './add_edit_rotation_form.vue';

export const i18n = {
  rotationCreated: s__('OnCallSchedules|Successfully created a new rotation'),
  editedRotation: s__('OnCallSchedules|Successfully edited your rotation'),
  addRotation: s__('OnCallSchedules|Add rotation'),
  editRotation: s__('OnCallSchedules|Edit rotation'),
  cancel: __('Cancel'),
};

export default {
  i18n,
  LENGTH_ENUM,
  components: {
    GlModal,
    GlAlert,
    AddEditRotationForm,
  },
  inject: ['projectPath'],
  props: {
    modalId: {
      type: String,
      required: true,
    },
    isEditMode: {
      type: Boolean,
      required: false,
      default: false,
    },
    schedule: {
      type: Object,
      required: true,
    },
  },
  apollo: {
    participants: {
      query: searchProjectMembersQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          search: this.ptSearchTerm,
        };
      },
      update({ project: { projectMembers: { nodes = [] } = {} } = {} } = {}) {
        return nodes.map(({ user }) => ({ ...user }));
      },
      error(error) {
        this.error = error;
      },
    },
  },
  data() {
    return {
      participants: [],
      loading: false,
      ptSearchTerm: '',
      form: {
        name: '',
        participants: [],
        rotationLength: {
          length: 1,
          unit: this.$options.LENGTH_ENUM.days,
        },
        startsAt: {
          date: null,
          time: 0,
        },
        endsAt: {
          date: null,
          time: 0,
        },
        restrictedTo: {
          from: 0,
          to: 0,
        },
      },
      error: '',
      validationState: {
        name: true,
        participants: true,
        startsAt: true,
        endsAt: true,
      },
    };
  },
  computed: {
    actionsProps() {
      return {
        primary: {
          text: this.title,
          attributes: [
            { variant: 'info' },
            { loading: this.loading },
            { disabled: !this.isFormValid },
          ],
        },
        cancel: {
          text: this.$options.i18n.cancel,
        },
      };
    },
    canFormSubmit() {
      return (
        isNameFieldValid(this.form.name) &&
        this.form.participants.length > 0 &&
        Boolean(this.form.startsAt.date)
      );
    },
    isFormValid() {
      return Object.values(this.validationState).every(Boolean) && this.canFormSubmit;
    },
    isLoading() {
      return this.loading || this.$apollo.queries.participants.loading;
    },
    rotationVariables() {
      const {
        name,
        rotationLength,
        participants,
        startsAt: { date: startDate, time: startTime },
        endsAt: { date: endDate, time: endTime },
      } = this.form;

      return {
        projectPath: this.projectPath,
        scheduleIid: this.schedule.iid,
        name,
        startsAt: {
          date: formatDate(startDate, 'yyyy-mm-dd'),
          time: format24HourTimeStringFromInt(startTime),
        },
        endsAt: endDate
          ? {
              date: formatDate(endDate, 'yyyy-mm-dd'),
              time: format24HourTimeStringFromInt(endTime),
            }
          : null,
        rotationLength: {
          ...rotationLength,
          length: parseInt(rotationLength.length, 10),
        },
        participants: getParticipantsForSave(participants),
      };
    },
    title() {
      return this.isEditMode ? this.$options.i18n.editRotation : this.$options.i18n.addRotation;
    },
    isEndDateValid() {
      const startsAt = this.form.startsAt.date?.getTime();
      const endsAt = this.form.endsAt.date?.getTime();

      if (!startsAt || !endsAt) {
        // If start or end is not present, we consider the end date valid
        return true;
      } else if (startsAt < endsAt) {
        return true;
      } else if (startsAt === endsAt) {
        return this.form.startsAt.time < this.form.endsAt.time;
      }
      return false;
    },
  },
  methods: {
    createRotation() {
      this.loading = true;

      this.$apollo
        .mutate({
          mutation: createOncallScheduleRotationMutation,
          variables: { input: this.rotationVariables },
        })
        .then(
          ({
            data: {
              oncallRotationCreate: {
                errors: [error],
              },
            },
          }) => {
            if (error) {
              throw error;
            }

            this.$refs.addEditScheduleRotationModal.hide();
            this.$emit('fetchRotationShifts');
            return createFlash({
              message: this.$options.i18n.rotationCreated,
              type: FLASH_TYPES.SUCCESS,
            });
          },
        )
        .catch((error) => {
          this.error = error;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    editRotation() {
      this.loading = true;
      const { projectPath, schedule } = this;

      this.$apollo
        .mutate({
          mutation: updateOncallScheduleRotationMutation,
          variables: { input: this.rotationVariables },
          update(store, { data }) {
            updateStoreAfterRotationEdit(
              store,
              getOncallSchedulesWithRotationsQuery,
              { ...data, scheduleIid: schedule.iid },
              {
                projectPath,
              },
            );
          },
        })
        .then(
          ({
            data: {
              oncallRotationUpdate: {
                errors: [error],
              },
            },
          }) => {
            if (error) {
              throw error;
            }

            this.$refs.addEditScheduleRotationModal.hide();
            return createFlash({
              message: this.$options.i18n.editedRotation,
              type: FLASH_TYPES.SUCCESS,
            });
          },
        )
        .catch((error) => {
          this.error = error;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    updateRotationForm({ type, value }) {
      set(this.form, type, value);
      this.validateForm(type);
    },
    filterParticipants(query) {
      this.ptSearchTerm = query;
    },
    validateForm(key) {
      if (key === 'name') {
        this.validationState.name = isNameFieldValid(this.form.name);
      } else if (key === 'participants') {
        this.validationState.participants = this.form.participants.length > 0;
      } else if (key === 'startsAt.date' || key === 'startsAt.time') {
        this.validationState.startsAt = Boolean(this.form.startsAt.date);
        this.validationState.endsAt = this.isEndDateValid;
      } else if (key === 'endsAt.date' || key === 'endsAt.time') {
        this.validationState.endsAt = this.isEndDateValid;
      }
    },
  },
};
</script>

<template>
  <gl-modal
    ref="addEditScheduleRotationModal"
    :modal-id="modalId"
    :title="title"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    modal-class="rotations-modal"
    @primary.prevent="isEditMode ? editRotation() : createRotation()"
  >
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <add-edit-rotation-form
      :validation-state="validationState"
      :form="form"
      :schedule="schedule"
      :participants="participants"
      :is-loading="isLoading"
      @update-rotation-form="updateRotationForm"
      @filter-participants="filterParticipants"
    />
  </gl-modal>
</template>
