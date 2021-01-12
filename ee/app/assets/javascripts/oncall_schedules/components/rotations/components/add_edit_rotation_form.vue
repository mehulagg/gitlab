<script>
import {
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlDatepicker,
  GlTokenSelector,
  GlAvatar,
  GlAvatarLabeled,
  GlToggle,
  GlCard,
} from '@gitlab/ui';
import {
  LENGTH_ENUM,
  HOURS_IN_DAY,
  CHEVRON_SKIPPING_SHADE_ENUM,
  CHEVRON_SKIPPING_PALETTE_ENUM,
} from 'ee/oncall_schedules/constants';
import { s__, __ } from '~/locale';
import { format24HourTimeStringFromInt } from '~/lib/utils/datetime_utility';

export const i18n = {
  selectParticipant: s__('OnCallSchedules|Select participant'),
  errorMsg: s__('OnCallSchedules|Failed to add rotation'),
  fields: {
    name: { title: __('Name'), error: s__('OnCallSchedules|Rotation name cannot be empty') },
    participants: {
      title: __('Participants'),
      error: s__('OnCallSchedules|Rotation participants cannot be empty'),
    },
    rotationLength: { title: s__('OnCallSchedules|Rotation length') },
    startsAt: {
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
};

export default {
  i18n,
  HOURS_IN_DAY,
  tokenColorPalette: {
    shade: CHEVRON_SKIPPING_SHADE_ENUM,
    palette: CHEVRON_SKIPPING_PALETTE_ENUM,
  },
  LENGTH_ENUM,
  components: {
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlDatepicker,
    GlTokenSelector,
    GlAvatar,
    GlAvatarLabeled,
    GlToggle,
    GlCard,
  },
  inject: ['projectPath'],
  props: {
    form: {
      type: Object,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
    validationState: {
      type: Object,
      required: true,
    },
    participants: {
      type: Array,
      required: true,
    },
    schedule: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      participantsArr: [],
      endDateEnabled: false,
      restrictToTimeEnabled: false,
    };
  },
  methods: {
    format24HourTimeStringFromInt,
  },
};
</script>

<template>
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
          @blur="$emit('update-rotation-form', { type: 'name', value: $event.target.value })"
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
          v-model="participantsArr"
          :dropdown-items="participants"
          :loading="isLoading"
          container-class="gl-h-13! gl-overflow-y-auto"
          @text-input="$emit('filter-participants', $event)"
          @blur="$emit('update-rotation-form', { type: 'participants', value: participantsArr })"
          @input="$emit('update-rotation-form', { type: 'participants', value: participantsArr })"
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
        :label="$options.i18n.fields.rotationLength.title"
        label-size="sm"
        label-for="rotation-length"
      >
        <div class="gl-display-flex">
          <gl-form-input
            id="rotation-length"
            type="number"
            class="gl-w-12 gl-mr-3"
            min="1"
            :value="1"
            @input="$emit('update-rotation-form', { type: 'rotationLength.length', value: $event })"
          />
          <gl-dropdown :text="form.rotationLength.unit.toLowerCase()">
            <gl-dropdown-item
              v-for="unit in $options.LENGTH_ENUM"
              :key="unit"
              :is-checked="form.rotationLength.unit === unit"
              is-check-item
              @click="$emit('update-rotation-form', { type: 'rotationLength.unit', value: unit })"
            >
              {{ unit.toLowerCase() }}
            </gl-dropdown-item>
          </gl-dropdown>
        </div>
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.startsAt.title"
        label-size="sm"
        :invalid-feedback="$options.i18n.fields.startsAt.error"
        :state="validationState.startsAt"
      >
        <div class="gl-display-flex gl-align-items-center">
          <gl-datepicker
            class="gl-mr-3"
            @input="$emit('update-rotation-form', { type: 'startsAt.date', value: $event })"
          >
            <template #default="{ formattedDate }">
              <gl-form-input
                class="gl-w-full"
                :value="formattedDate"
                :placeholder="__(`YYYY-MM-DD`)"
                @blur="
                  $emit('update-rotation-form', {
                    type: 'startsAt.date',
                    value: $event.target.value,
                  })
                "
              />
            </template>
          </gl-datepicker>
          <span> {{ __('at') }} </span>
          <gl-dropdown
            data-testid="rotation-start-time"
            :text="format24HourTimeStringFromInt(form.startsAt.time)"
            class="gl-w-12 gl-pl-3"
          >
            <gl-dropdown-item
              v-for="time in $options.HOURS_IN_DAY"
              :key="time"
              :is-checked="form.startsAt.time === time"
              is-check-item
              @click="$emit('update-rotation-form', { type: 'startsAt.time', value: time })"
            >
              <span class="gl-white-space-nowrap"> {{ format24HourTimeStringFromInt(time) }}</span>
            </gl-dropdown-item>
          </gl-dropdown>
          <span class="gl-pl-5"> {{ schedule.timezone }} </span>
        </div>
      </gl-form-group>
    </div>

    <gl-toggle
      v-model="endDateEnabled"
      :label="$options.i18n.fields.endsOn.enableToggle"
      label-position="left"
      class="gl-mb-5"
    />

    <gl-card v-if="endDateEnabled" data-testid="rotation-ends-on">
      <gl-form-group
        :label="$options.i18n.fields.endsOn.title"
        label-size="sm"
        :invalid-feedback="$options.i18n.fields.endsOn.error"
      >
        <div class="gl-display-flex gl-align-items-center">
          <gl-datepicker
            class="gl-mr-3"
            @input="$emit('update-rotation-form', { type: 'endsOn.date', value: $event })"
          />
          <span> {{ __('at') }} </span>
          <gl-dropdown
            data-testid="rotation-end-time"
            :text="format24HourTimeStringFromInt(form.endsOn.time)"
            class="gl-w-12 gl-pl-3"
          >
            <gl-dropdown-item
              v-for="time in $options.HOURS_IN_DAY"
              :key="time"
              :is-checked="form.endsOn.time === time"
              is-check-item
              @click="$emit('update-rotation-form', { type: 'endsOn.time', value: time })"
            >
              <span class="gl-white-space-nowrap"> {{ format24HourTimeStringFromInt(time) }}</span>
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

    <gl-card v-if="restrictToTimeEnabled" data-testid="restricted-to-time">
      <gl-form-group
        :label="$options.i18n.fields.restrictToTime.title"
        label-size="sm"
        :invalid-feedback="$options.i18n.fields.endsOn.error"
      >
        <div class="gl-display-flex gl-align-items-center">
          <span> {{ __('From') }} </span>
          <gl-dropdown
            data-testid="restricted-from"
            :text="format24HourTimeStringFromInt(form.restrictedTo.from)"
            class="gl-px-3"
          >
            <gl-dropdown-item
              v-for="time in $options.HOURS_IN_DAY"
              :key="time"
              :is-checked="form.restrictedTo.from === time"
              is-check-item
              @click="$emit('update-rotation-form', { type: 'restrictedTo.from', value: time })"
            >
              <span class="gl-white-space-nowrap"> {{ format24HourTimeStringFromInt(time) }}</span>
            </gl-dropdown-item>
          </gl-dropdown>
          <span> {{ __('To') }} </span>
          <gl-dropdown
            data-testid="restricted-to"
            :text="format24HourTimeStringFromInt(form.restrictedTo.to)"
            class="gl-px-3"
          >
            <gl-dropdown-item
              v-for="time in $options.HOURS_IN_DAY"
              :key="time"
              :is-checked="form.restrictedTo.to === time"
              is-check-item
              @click="$emit('update-rotation-form', { type: 'restrictedTo.to', value: time })"
            >
              <span class="gl-white-space-nowrap"> {{ format24HourTimeStringFromInt(time) }}</span>
            </gl-dropdown-item>
          </gl-dropdown>
        </div>
      </gl-form-group>
    </gl-card>
  </gl-form>
</template>
