<script>
import { GlFormGroup } from '@gitlab/ui';
import { mapActions, mapGetters } from 'vuex';
import DateTimePicker from '~/vue_shared/components/date_time_picker/date_time_picker.vue';
import { timeRanges, defaultTimeRange } from '~/vue_shared/constants';
import EnvironmentPicker from './filters/environment_picker.vue';

export default {
  name: 'ThreatMonitoringFilters',
  components: {
    GlFormGroup,
    DateTimePicker,
    EnvironmentPicker,
  },
  data() {
    return {
      selectedTimeRange: defaultTimeRange,
      timeRanges,
    };
  },
  computed: {
    ...mapGetters('threatMonitoring', ['canChangeEnvironment']),
  },
  methods: {
    ...mapActions('threatMonitoring', ['setCurrentTimeWindow']),
    onDateTimePickerInput(timeRange) {
      this.selectedTimeRange = timeRange;
      this.setCurrentTimeWindow(timeRange);
    },
  },
};
</script>

<template>
  <div class="pt-3 px-3 bg-gray-light">
    <div class="row">
      <environment-picker />

      <gl-form-group
        :label="s__('ThreatMonitoring|Show last')"
        label-size="sm"
        label-for="threat-monitoring-time-window-dropdown"
        class="col-sm-6 col-md-6 col-lg-4"
      >
        <date-time-picker
          ref="dateTimePicker"
          :custom-enabled="false"
          :value="selectedTimeRange"
          :options="timeRanges"
          :disabled="!canChangeEnvironment"
          @input="onDateTimePickerInput"
        />
      </gl-form-group>
    </div>
  </div>
</template>
