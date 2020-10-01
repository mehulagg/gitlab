<script>
import {
  GlButton,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlFormSelect,
  GlFormText,
  GlIcon,
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
    multiplier: 60,
  },
};

export default {
  i18n: {
    description: __(`You may choose to introduce a countdown timer in incident issues
    to better track Service Level Aggreements (SLAs). The timer is automatically started
    when the incident is created, and sets a time limit for the incident to be resolved
    in. When activated, "time to SLA" countdown will appear on all incidents and it will
    automatically start counting down as soon as the issue is created. Should the time
    limit be exceeded, a system note and a label will be added to the issue as a note
    that the incident was not resolved within the time allotted.`),
  },
  units: Object.values(units),
  components: {
    GlButton,
    GlFormCheckbox,
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
    GlFormText,
    GlIcon,
    GlLink,
    GlSprintf,
  },
  inject: ['service', 'serviceLevelAgreementSettings'],
  data() {
    return {
      duration: this.serviceLevelAgreementSettings.minutes ?? '',
      enabled: this.serviceLevelAgreementSettings.active,
      loading: false,
      success: false,
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
        return __('Time limit must be greater than 0');
      }

      const minutes = duration * units[this.unit].multiplier;
      if (minutes % 15 !== 0) {
        return __('Time limit must be a multiple of 15 minutes');
      }
      return '';
    },
    isValid() {
      return this.duration !== '' && this.invalidFeedback === '';
    },
  },
  methods: {
    updateServiceLevelAgreementSettings() {
      this.loading = true;
      this.success = false;

      return this.service
        .updateSettings({
          sla_timer: this.enabled,
          sla_timer_minutes: this.duration * units[this.unit].multiplier,
        })
        .then(() => {
          this.success = true;
        })
        .finally(() => {
          this.loading = false;
        });
    },
  },
};
</script>

<template>
  <form @submit.prevent="updateServiceLevelAgreementSettings">
    <p class="gl-line-height-20">
      {{ $options.i18n.description }}
    </p>
    <gl-form-checkbox v-model="enabled" class="gl-my-4" @input="success = false">
      <span>{{ __('Activate "time to SLA" countdown timer') }}</span>
      <gl-form-text class="gl-text-gray-400 gl-font-base">
        {{ __('When activated, this will apply to all incidents within the project') }}
      </gl-form-text>
    </gl-form-checkbox>
    <gl-form-group
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
          @input="success = false"
        />
        <gl-form-select
          v-model="unit"
          :options="$options.units"
          class="gl-w-auto gl-ml-3 gl-line-height-normal gl-border-gray-400"
          @input="success = false"
        />
      </div>
    </gl-form-group>
    <gl-button
      ref="submitBtn"
      variant="success"
      type="submit"
      :disabled="!isValid || loading"
      :loading="loading"
      class="js-no-auto-disable"
    >
      {{ __('Save changes') }}
    </gl-button>

    <gl-icon
      v-show="success"
      class="js-error-tracking-connect-success gl-ml-3 text-success align-middle"
      :aria-label="__('Saved successfully')"
      name="check-circle"
    />
  </form>
</template>
