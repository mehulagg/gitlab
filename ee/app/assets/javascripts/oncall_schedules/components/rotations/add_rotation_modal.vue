<script>
import {
  GlModal,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlDatepicker,
  GlTokenSelector,
  GlAvatar,
  GlAvatarLabeled,
  GlAlert,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import usersSearchQuery from '~/graphql_shared/queries/users_search.query.graphql';
import createOncallScheduleRotationMutation from '../../graphql/create_oncall_schedule_rotation.mutation.graphql';
import {
  LENGTH_ENUM,
  CHEVRON_SKIPPING_SHADE_ENUM,
  CHEVRON_SKIPPING_PALETTE_ENUM,
} from '../../constants';

export default {
  i18n: {
    selectParticipant: s__('OnCallSchedules|Select participant'),
    addRotation: s__('OnCallSchedules|Add rotation'),
    noResults: __('No matching results'),
    cancel: __('Cancel'),
    errorMsg: s__('OnCallSchedules|Failed to add rotation'),
    fields: {
      name: { title: __('Name'), error: s__('OnCallSchedules|Rotation name cannot be empty') },
      participants: {
        title: __('Participants'),
        error: s__('OnCallSchedules|Rotation participants cannot be empty'),
      },
      length: { title: s__('OnCallSchedules|Rotation length') },
      startsOn: {
        title: __('Starts on'),
        error: s__('OnCallSchedules|Rotation start date cannot be empty'),
      },
    },
  },
  tokenColorPalette: {
    shade: CHEVRON_SKIPPING_SHADE_ENUM,
    palette: CHEVRON_SKIPPING_PALETTE_ENUM,
  },
  LENGTH_ENUM,
  inject: ['projectPath'],
  components: {
    GlModal,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlDatepicker,
    GlTokenSelector,
    GlAvatar,
    GlAvatarLabeled,
    GlAlert,
  },
  props: {
    modalId: {
      type: String,
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
        this.showErrorAlert = true;
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
        length: {
          value: 1,
          type: this.$options.LENGTH_ENUM.hours,
        },
        startsOn: {
          date: null,
          time: 0,
        },
      },
      showErrorAlert: false,
      error: '',
    };
  },
  computed: {
    actionsProps() {
      return {
        primary: {
          text: this.$options.i18n.addRotation,
          attributes: [{ variant: 'info' }, { loading: this.loading }],
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
    rotationStartsOnIsValid() {
      return this.form.startsOn.date !== null || this.form.startsOn.date !== undefined;
    },
    noResults() {
      return this.participants.length === 0;
    },
  },
  methods: {
    createRotation() {
      this.loading = true;
      this.$apollo
        .mutate({
          mutation: createOncallScheduleRotationMutation,
          variables: {
            oncallScheduleRotationCreate: {
              projectPath: this.projectPath,
              ...this.form,
            },
          },
        })
        .then(({ data: { oncallScheduleRotationCreate: { errors: [error] } } }) => {
          if (error) {
            throw error;
          }
          this.$refs.createScheduleModal.hide();
        })
        .catch(error => {
          this.error = error;
          this.showErrorAlert = true;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    formatTime(time) {
      return time > 9 ? `${time}:00` : `0${time}:00`;
    },
    filterParticipants(query) {
      this.ptSearchTerm = query;
    },
    setRotationLengthType(type) {
      this.form.length.type = type;
    },
    setRotationStartsOnTime(time) {
      this.form.startsOn.time = time;
    },
  },
};
</script>

<template>
  <gl-modal
    ref="createScheduleRotationModal"
    :modal-id="modalId"
    size="sm"
    :title="$options.i18n.addRotation"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary="createRotation"
  >
    <gl-alert v-if="showErrorAlert" variant="danger" @dismiss="showErrorAlert = false">
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <gl-form class="w-75 gl-xs-w-full!" @submit.prevent="createRotation">
      <gl-form-group
        :label="$options.i18n.fields.name.title"
        label-size="sm"
        label-for="rotation-name"
        :invalid-feedback="$options.i18n.fields.name.error"
        :state="rotationNameIsValid"
      >
        <gl-form-input id="rotation-name" v-model="form.name" />
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.participants.title"
        label-size="sm"
        label-for="rotation-participants"
        :invalid-feedback="$options.i18n.fields.participants.error"
        :state="rotationParticipantsAreValid"
      >
        <gl-token-selector
          v-model="form.participants"
          :dropdown-items="participants"
          :loading="this.$apollo.queries.participants.loading"
          :container-class="'gl-h-13! gl-overflow-y-auto'"
          @text-input="filterParticipants"
        >
          <template #token-content="{ token }">
            <gl-avatar v-if="token.avatarUrl" :src="token.avatarUrl" :size="16" />
            {{ token.name }}
          </template>
          <template #dropdown-item-content="{ dropdownItem }">
            <gl-avatar-labeled
              :src="dropdownItem.avatarUrl"
              :size="32"
              :label="dropdownItem.name"
              :sub-label="dropdownItem.username"
            />
          </template>
        </gl-token-selector>
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.length.title"
        label-size="sm"
        label-for="rotation-length"
      >
        <div class="gl-display-flex">
          <gl-form-input
            id="rotation-length"
            v-model="form.length.value"
            type="number"
            class="gl-w-12 gl-mr-3"
            min="1"
          />
          <gl-dropdown id="rotation-length" :text="form.length.type">
            <gl-dropdown-item
              v-for="type in $options.LENGTH_ENUM"
              :key="type"
              :is-checked="form.length.type === type"
              is-check-item
              @click="setRotationLengthType(type)"
            >
              {{ type }}
            </gl-dropdown-item>
          </gl-dropdown>
        </div>
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.startsOn.title"
        label-size="sm"
        label-for="rotation-time"
        :invalid-feedback="$options.i18n.fields.startsOn.error"
        :state="rotationStartsOnIsValid"
      >
        <div class="gl-display-flex gl-align-items-center">
          <gl-datepicker v-model="form.startsOn.date" class="gl-mr-3" />
          <span> {{ __('at') }} </span>
          <gl-dropdown
            id="rotation-time"
            :text="formatTime(form.startsOn.time)"
            class="gl-w-12 gl-pl-3"
          >
            <gl-dropdown-item
              v-for="n in 24"
              :key="n"
              :is-checked="form.startsOn.time === n"
              is-check-item
              @click="setRotationStartsOnTime(n)"
            >
              <span class="gl-white-space-nowrap"> {{ formatTime(n) }}</span>
            </gl-dropdown-item>
          </gl-dropdown>
          <!-- TODO: // Replace with actual timezone following coming work -->
          <span class="gl-pl-5"> {{ __('PST') }} </span>
        </div>
      </gl-form-group>
    </gl-form>
  </gl-modal>
</template>
