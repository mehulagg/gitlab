<script>
import { GlModal, GlAlert } from '@gitlab/ui';
import { set } from 'lodash';
import { s__, __ } from '~/locale';
import createFlash, { FLASH_TYPES } from '~/flash';
import usersSearchQuery from '~/graphql_shared/queries/users_search.query.graphql';
import getOncallSchedulesQuery from '../../../graphql/queries/get_oncall_schedules.query.graphql';
import createOncallScheduleRotationMutation from '../../../graphql/mutations/create_oncall_schedule_rotation.mutation.graphql';
import updateOncallScheduleRotationMutation from '../../../graphql/mutations/update_oncall_schedule_rotation.mutation.graphql';
import { LENGTH_ENUM } from '../../../constants';
import AddEditRotationForm from './add_edit_rotation_form.vue';
import {
  updateStoreAfterRotationAdd,
  updateStoreAfterRotationEdit,
} from '../../../utils/cache_updates';
import { format24HourTimeStringFromInt } from '~/lib/utils/datetime_utility';

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
  inject: ['projectPath'],
  components: {
    GlModal,
    GlAlert,
    AddEditRotationForm,
  },
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
      query: usersSearchQuery,
      variables() {
        return {
          search: this.ptSearchTerm,
        };
      },
      update({ users: { nodes = [] } = {} }) {
        return nodes;
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
          unit: this.$options.LENGTH_ENUM.hours,
        },
        startsAt: {
          date: null,
          time: 0,
        },
      },
      error: '',
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
    rotationNameIsValid() {
      return this.form.name !== '';
    },
    rotationParticipantsAreValid() {
      return this.form.participants.length > 0;
    },
    rotationStartsAtIsValid() {
      return Boolean(this.form.startsAt.date);
    },
    rotationVariables() {
      return {
        projectPath: this.projectPath,
        scheduleIid: this.schedule.iid,
        name: this.form.name,
        startsAt: {
          ...this.form.startsAt,
          time: format24HourTimeStringFromInt(this.form.startsAt.time),
        },
        rotationLength: {
          ...this.form.rotationLength,
          length: parseInt(this.form.rotationLength.length, 10),
        },
        participants: this.form.participants.map(({ username }) => ({
          username,
          // eslint-disable-next-line @gitlab/require-i18n-strings
          colorWeight: 'WEIGHT_500',
          colorPalette: 'BLUE',
        })),
      };
    },
    isFormValid() {
      return (
        this.rotationNameIsValid &&
        this.rotationParticipantsAreValid &&
        this.rotationStartsAtIsValid
      );
    },
    isLoading() {
      return this.loading || this.$apollo.queries.participants.loading;
    },
    title() {
      return this.isEditMode ? this.$options.i18n.editRotation : this.$options.i18n.addRotation;
    },
  },
  methods: {
    createRotation() {
      this.loading = true;
      const { projectPath, schedule } = this;

      this.$apollo
        .mutate({
          mutation: createOncallScheduleRotationMutation,
          variables: { OncallRotationCreateInput: this.rotationVariables },
          update(store, { data }) {
            updateStoreAfterRotationAdd(store, getOncallSchedulesQuery, data, schedule.iid, {
              projectPath,
            });
          },
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
          variables: { OncallRotationUpdateInput: this.rotationVariables },
          update(store, { data }) {
            updateStoreAfterRotationEdit(store, getOncallSchedulesQuery, data, schedule.iid, {
              projectPath,
            });
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
    },
    filterParticipants(query) {
      this.ptSearchTerm = query;
    },
  },
};
</script>

<template>
  <gl-modal
    ref="addEditScheduleRotationModal"
    :modal-id="modalId"
    size="sm"
    :title="title"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary.prevent="isEditMode ? editRotation() : createRotation()"
  >
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <add-edit-rotation-form
      :rotation-name-is-valid="rotationNameIsValid"
      :rotation-participants-are-valid="rotationParticipantsAreValid"
      :rotation-starts-at-is-valid="rotationStartsAtIsValid"
      :form="form"
      :schedule="schedule"
      :participants="participants"
      :is-loading="isLoading"
      @update-rotation-form="updateRotationForm"
      @filter-participants="filterParticipants"
    />
  </gl-modal>
</template>
