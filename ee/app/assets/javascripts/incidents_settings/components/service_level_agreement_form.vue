<script>
import {
  GlButton,
  GlForm,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlFormSelect,
  GlFormText,
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
    to better track Service Level Agreements (SLAs). The timer is automatically started when the incident
    is created, and sets a time limit for the incident to be resolved in. When activated, "time to SLA"
    countdown will appear on all new incidents.`),
  },
  units: Object.values(units),
  components: {
    GlButton,
    GlForm,
    GlFormCheckbox,
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
    GlFormText,
    GlTab,
  },
  inject: ['service', 'serviceLevelAgreementSettings'],
  data() {
    return {
      available: this.serviceLevelAgreementSettings.available,
      duration: this.serviceLevelAgreementSettings.minutes ?? '',
      enabled: this.serviceLevelAgreementSettings.active,
      loading: false,
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

      return this.service
        .updateSettings({
          sla_timer: this.enabled,
          sla_timer_minutes: this.duration * units[this.unit].multiplier,
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
    <gl-form class="gl-pt-3" @submit.prevent="updateServiceLevelAgreementSettings">
      <p class="gl-line-height-20">
        {{ $options.i18n.description }}
      </p>
      <gl-form-checkbox v-model="enabled" class="gl-my-4">
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
        label-for="sla-duration"
        :state="isValid"
      >
        <div class="gl-display-flex gl-flex-direction-row">
          <gl-form-input id="sla-duration" v-model="duration" type="number" number size="xs" trim />
          <gl-form-select
            v-model="unit"
            :options="$options.units"
            class="gl-w-auto gl-ml-3 gl-line-height-normal gl-border-gray-400"
          />
        </div>
      </gl-form-group>
      <gl-button variant="success" type="submit" :disabled="!isValid || loading" :loading="loading">
        {{ __('Save changes') }}
      </gl-button>
    </gl-form>
  </gl-tab>
</template>
