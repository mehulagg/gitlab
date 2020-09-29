<script>
import {
  GlButton,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlFormSelect,
  GlFormText,
  GlLink,
  GlSprintf,
} from '@gitlab/ui';
import { __ } from '~/locale';

const units = {
  minutes: {
    value: 'minutes',
    text: __('minutes'),
    multiplier: 1,
  },
  hours: {
    value: 'hours',
    text: __('hours'),
    multiplier: 60
  }
};

export default {
  i18n: {
    description: __(`You may choose to introduce a countdown timer in incident issues
    to better track Service Level Aggreements (SLAs). The timer is automatically started
    when the incident is created, and sets a time limit for the incident to be resolved
    in. When activated, "time to SLA" countdown will appear on all incidents and it will
    automatically start counting down as soon as the issue is created. Should the time
    limit be exceeded, a system note and a label will be added to the issue as a note
    that the incident was not resolved within the time allotted.
    %{linkStart}More information%{linkEnd}`),
  },
  units: Object.values(units),
  components: {
    GlButton,
    GlFormCheckbox,
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
    GlFormText,
    GlLink,
    GlSprintf,
  },
  inject: ['service'],
  data() {
    return {
      enabled: false,
      duration: '',
      unit: units.minutes.value,
    };
  },
  computed: {
    invalidFeedback() {
      // Don't validate when checkbox is disabled
      if (!this.enabled) {
        return '';
      }

      // Don't validate the default state
      if (this.duration === '') {
        return '';
      }

      const duration = Number(this.duration);
      if (Number.isNaN(duration)) {
        return __('Time limit must be a valid number');
      }
      if (duration <= 0) {
        return __('Time limit must be greater than 0')
      }

      const minutes = duration * units[this.unit].multiplier;
      if (minutes % 15 !== 0) {
        return __('Time limit must be a multiple of 15 minutes')
      }
      return '';
    },
    isValid() {
      return this.duration !== '' && this.invalidFeedback === '';
    },
  },
};
</script>

<template>
  <div>
    <p class="gl-line-height-20">
      <gl-sprintf :message="$options.i18n.description">
        <template #link="{ content }">
          <!-- TODO: add docs -->
          <gl-link href="/docs">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
    <gl-form-checkbox v-model="enabled" class="gl-my-4">
      <span>{{ __('Activate "time to SLA" countdown timer') }}</span>
      <gl-form-text class="gl-text-gray-400 gl-font-base">
        {{ __('When activated, this will apply to all incidents within the project') }}
      </gl-form-text>
    </gl-form-checkbox>
    <!-- TODO: is id required for form groups? -->
    <gl-form-group
      id="group-sla-time"
      :invalid-feedback="invalidFeedback"
      :label="__('Time limit')"
      label-for="sla-time"
      :state="isValid"
    >
      <div class="gl-display-flex gl-flex-direction-row">
        <gl-form-input
          id="sla-time"
          v-model="duration"
          type="number"
          number
          size="xs"
          trim
        />
        <gl-form-select v-model="unit" :options="$options.units" class="gl-w-auto gl-ml-3 gl-line-height-normal gl-border-gray-400"/>
      </div>
    </gl-form-group>
    <gl-button
      ref="submitBtn"
      variant="success"
      type="submit"
      :disabled="!isValid"
      class="js-no-auto-disable"
    >
      {{ __('Save changes') }}
    </gl-button>
  </div>
</template>
