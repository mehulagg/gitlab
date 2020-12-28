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
  GlToggle,
  GlCard,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import usersSearchQuery from '~/graphql_shared/queries/users_search.query.graphql';
import createOncallScheduleRotationMutation from '../../../graphql/create_oncall_schedule_rotation.mutation.graphql';
import {
  LENGTH_ENUM,
  CHEVRON_SKIPPING_SHADE_ENUM,
  CHEVRON_SKIPPING_PALETTE_ENUM,
} from '../../../constants';

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
      endsOn: {
        enableToggle: s__('OnCallSchedules|Enable end date'),
        title: __('Ends on'),
      },
      restrictToTime: {
        enableToggle: s__('OnCallSchedules|Restrict to time intervals'),
        title: s__('OnCallSchedules|For this rotation, on-call will be:'),
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
    GlToggle,
    GlCard,
  },
  props: {
    modalId: {
      type: String,
      required: true,
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
      endDateEnabled: false,
      restrictToTimeEnabled: false,
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
        endsOn: {
          date: null,
          time: 0,
        },
        restrictedTo: {
          from: 0,
          to: 0,
        },
      },
      error: null,
      validationState: {
        name: true,
        participants: true,
        startsOn: true,
      },
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
        .then(
          ({
            data: {
              oncallScheduleRotationCreate: {
                errors: [error],
              },
            },
          }) => {
            if (error) {
              throw error;
            }
            this.$refs.createScheduleModal.hide();
          },
        )
        .catch((error) => {
          this.error = error;
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
    setRotationEndsOnTime(time) {
      this.form.endsOn.time = time;
    },
    setRestrictedFrom(time) {
      this.form.restrictedTo.from = time;
    },
    setRestrictedTo(time) {
      this.form.restrictedTo.to = time;
    },
    validateForm(key) {
      if (key === 'name') {
        this.validationState.name = this.form.name !== '';
      } else if (key === 'participants') {
        this.validationState.participants = this.form.participants.length > 0;
      } else if (key === 'startsOn') {
        this.validationState.startsOn = this.form.startsOn.date !== null;
      }
    },
  },
};
</script>

<template>
  <gl-modal
    ref="createScheduleRotationModal"
    :modal-id="modalId"
    :title="$options.i18n.addRotation"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    modal-class="rotations-modal"
    @primary="createRotation"
  >
    <gl-alert v-if="error" variant="danger" @dismiss="error = null">
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <gl-form @submit.prevent="createRotation">
      <div class="w-75 gl-xs-w-full!">
        <gl-form-group
          :label="$options.i18n.fields.name.title"
          label-size="sm"
          label-for="rotation-name"
          :invalid-feedback="$options.i18n.fields.name.error"
          :state="validationState.name"
        >
          <gl-form-input
            id="rotation-name"
            v-model="form.name"
            @blur.native="validateForm('name')"
          />
        </gl-form-group>

        <gl-form-group
          :label="$options.i18n.fields.participants.title"
          label-size="sm"
          label-for="rotation-participants"
          :invalid-feedback="$options.i18n.fields.participants.error"
          :state="validationState.participants"
        >
          <gl-token-selector
            v-model="form.participants"
            :dropdown-items="participants"
            :loading="this.$apollo.queries.participants.loading"
            :container-class="'gl-h-13! gl-overflow-y-auto'"
            @text-input="filterParticipants"
            @blur="validateForm('participants')"
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
            <gl-dropdown :text="form.length.type">
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
          label-for="rotation-start-time"
          :invalid-feedback="$options.i18n.fields.startsOn.error"
          :state="validationState.startsOn"
        >
          <div class="gl-display-flex gl-align-items-center">
            <gl-datepicker
              v-model="form.startsOn.date"
              class="gl-mr-3"
              @close="validateForm('startsOn')"
            />
            <span> {{ __('at') }} </span>
            <gl-dropdown
              id="rotation-start-time"
              :text="formatTime(form.startsOn.time)"
              class="gl-w-12 gl-pl-3"
            >
              <gl-dropdown-item
                v-for="hour in 24"
                :key="hour"
                :is-checked="form.startsOn.time === hour"
                is-check-item
                @click="setRotationStartsOnTime(hour)"
              >
                <span class="gl-white-space-nowrap"> {{ formatTime(hour) }}</span>
              </gl-dropdown-item>
            </gl-dropdown>
            <span class="gl-pl-5"> {{ schedule.timezone }} </span>
          </div>
        </gl-form-group>
      </div>

      <gl-toggle
        v-model="endDateEnabled"
        data-testid="end-date-toggle"
        :label="$options.i18n.fields.endsOn.enableToggle"
        label-position="left"
        class="gl-mb-5"
      />

      <gl-card v-if="endDateEnabled" class="gl-min-w-fit-content" data-testid="ends-on">
        <gl-form-group
          :label="$options.i18n.fields.endsOn.title"
          label-size="sm"
          label-for="rotation-end-time"
          :invalid-feedback="$options.i18n.fields.endsOn.error"
          :state="validationState.endsOn"
        >
          <div class="gl-display-flex gl-align-items-center">
            <gl-datepicker v-model="form.endsOn.date" class="gl-mr-3" />
            <span> {{ __('at') }} </span>
            <gl-dropdown
              id="rotation-end-time"
              :text="formatTime(form.endsOn.time)"
              class="gl-pl-3"
            >
              <gl-dropdown-item
                v-for="hour in 24"
                :key="hour"
                :is-checked="form.endsOn.time === hour"
                is-check-item
                @click="setRotationEndsOnTime(hour)"
              >
                <span class="gl-white-space-nowrap"> {{ formatTime(hour) }}</span>
              </gl-dropdown-item>
            </gl-dropdown>
            <div class="gl-mx-5">{{ schedule.timezone }}</div>
          </div>
        </gl-form-group>
      </gl-card>

      <gl-toggle
        v-model="restrictToTimeEnabled"
        data-testid="restricted-to-toggle"
        :label="$options.i18n.fields.restrictToTime.enableToggle"
        label-position="left"
        class="gl-my-5"
      />

      <gl-card
        v-if="restrictToTimeEnabled"
        class="gl-min-w-fit-content"
        data-testid="restricted-to-time"
      >
        <gl-form-group
          :label="$options.i18n.fields.restrictToTime.title"
          label-size="sm"
          label-for="rotation-restrict-to-time"
          :invalid-feedback="$options.i18n.fields.endsOn.error"
          :state="validationState.endsOn"
        >
          <div id="rotation-restrict-to-time" class="gl-display-flex gl-align-items-center">
            <span> {{ __('From') }} </span>
            <gl-dropdown
              data-testid="restricted-from"
              :text="formatTime(form.restrictedTo.from)"
              class="gl-px-3"
            >
              <gl-dropdown-item
                v-for="hour in 24"
                :key="hour"
                :is-checked="form.restrictedTo.from === hour"
                is-check-item
                @click="setRestrictedFrom(hour)"
              >
                <span class="gl-white-space-nowrap"> {{ formatTime(hour) }}</span>
              </gl-dropdown-item>
            </gl-dropdown>
            <span> {{ __('To') }} </span>
            <gl-dropdown
              data-testid="restricted-to"
              :text="formatTime(form.restrictedTo.to)"
              class="gl-px-3"
            >
              <gl-dropdown-item
                v-for="hour in 24"
                :key="hour"
                :is-checked="form.restrictedTo.to === hour"
                is-check-item
                @click="setRestrictedTo(hour)"
              >
                <span class="gl-white-space-nowrap"> {{ formatTime(hour) }}</span>
              </gl-dropdown-item>
            </gl-dropdown>
          </div>
        </gl-form-group>
      </gl-card>
    </gl-form>
  </gl-modal>
</template>
