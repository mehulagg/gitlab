<script>
import {
  GlButton,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlFormSelect,
  GlFormText,
  GlIcon,
  GlTab,
} from '@gitlab/ui';
import { s__ } from '~/locale';

const units = {
  minutes: {
    value: 'minutes',
    text: s__('IncidentSettings|minutes'),
    multiplier: 1,
  },
  hours: {
    value: 'hours',
    text: s__('IncidentSettings|hours'),
    multiplier: 60,
  },
};

export default {
  i18n: {
    description: s__(`IncidentSettings|You may choose to introduce a countdown timer in incident issues
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
    GlTab,
  },
  inject: ['service', 'serviceLevelAgreementSettings'],
  data() {
    return {
      available: this.serviceLevelAgreementSettings.available,
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
        return s__('IncidentSettings|Time limit must be a valid number');
      }
      if (duration <= 0) {
        return s__('IncidentSettings|Time limit must be greater than 0');
      }

      const minutes = duration * units[this.unit].multiplier;
      if (minutes % 15 !== 0) {
        return s__('IncidentSettings|Time limit must be a multiple of 15 minutes');
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
  <gl-tab
    v-if="available"
    key="service-level-agreement"
    :title="s__('IncidentSettings|Incident Settings')"
  >
    <form class="gl-pt-3" @submit.prevent="updateServiceLevelAgreementSettings">
      <p class="gl-line-height-20">
        {{ $options.i18n.description }}
      </p>
      <gl-form-checkbox v-model="enabled" class="gl-my-4" @input="success = false">
        <span>{{ s__('IncidentSettings|Activate "time to SLA" countdown timer') }}</span>
        <gl-form-text class="gl-text-gray-400 gl-font-base">
          {{
            s__(
              'IncidentSettings|When activated, this will apply to all incidents within the project',
            )
          }}
        </gl-form-text>
      </gl-form-checkbox>
      <gl-form-group
        :invalid-feedback="invalidFeedback"
        :label="s__('IncidentSettings|Time limit')"
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
      <!-- TODO: clean up classes -->
      <gl-icon
        v-show="success"
        class="gl-ml-3 gl-text-green-500 gl-vertical-align-middle!"
        :aria-label="__('Saved successfully')"
        name="check-circle"
      />
    </form>
  </gl-tab>
</template>
