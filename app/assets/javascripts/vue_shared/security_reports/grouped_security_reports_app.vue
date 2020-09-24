<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import ReportSection from '~/reports/components/report_section.vue';
import { status } from '~/reports/constants';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    ReportSection,
  },
  props: {
    enabledReports: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      // TODO
      status: status.LOADING,
    };
  },
  computed: {
    hasSastReports() {
      return this.enabledReports.sast;
    },
    hasSecretScanningReports() {
      return this.enabledReports.secretDetection;
    },
  },
};
</script>
<template>
  <!-- TODO: check classes -->
  <report-section
    :status="status"
    :has-issues="false"
    class="mr-widget-border-top grouped-security-reports mr-report"
  >
    <template #loading>
      {{ __(`loading`) }}
    </template>

    <template #success>
      {{ __(`success`) }}
    </template>

    <template #error>
      {{ __(`error`) }}
    </template>

    <template #actionButtons>
      <gl-dropdown icon="download" :text="s__('FIXME|Download results')" right>
        <gl-dropdown-item>{{ __('Foo') }}</gl-dropdown-item>
      </gl-dropdown>
    </template>
  </report-section>
</template>
