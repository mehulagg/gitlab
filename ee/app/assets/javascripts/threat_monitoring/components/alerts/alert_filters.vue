<script>
import { GlFormCheckbox, GlFormGroup } from '@gitlab/ui';
import { s__ } from '~/locale';
import { DEFAULT_FILTERS } from './constants';

export default {
  DEFAULT_DISMISSED_FILTER: true,
  components: { GlFormCheckbox, GlFormGroup },
  i18n: {
    HIDE_DISMISSED_TITLE: s__('ThreatMonitoring|Hide dismissed alerts'),
  },
  methods: {
    changeDismissedFilter(filtered) {
      const newFilters = filtered ? DEFAULT_FILTERS : {};
      this.$emit('filter-change', newFilters);
    },
  },
};
</script>

<template>
  <div
    class="gl-pt-3 gl-px-3 gl-bg-gray-10 gl-display-flex gl-justify-content-end gl-align-items-center"
  >
    <gl-form-group label-size="sm">
      <gl-form-checkbox
        class="gl-mt-3"
        :checked="$options.DEFAULT_DISMISSED_FILTER"
        @change="changeDismissedFilter"
      >
        {{ $options.i18n.HIDE_DISMISSED_TITLE }}
      </gl-form-checkbox>
    </gl-form-group>
  </div>
</template>
