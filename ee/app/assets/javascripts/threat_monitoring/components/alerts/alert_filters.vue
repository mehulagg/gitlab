<script>
import { GlFormCheckbox, GlFormGroup } from '@gitlab/ui';
import { DEFAULT_FILTERS } from './constants';

export default {
  components: { GlFormCheckbox, GlFormGroup },
  props: {
    filters: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      filterDismissed: true,
    };
  },
  methods: {
    changeDismissedFilter() {
      const filterStatus = !this.filterDismissed;
      let newFilters;
      if (!filterStatus) {
        newFilters = {};
      } else {
        newFilters = DEFAULT_FILTERS;
      }
      this.$emit('filter-change', newFilters);
      this.filterDismissed = filterStatus;
    },
  },
};
</script>

<template>
  <div
    class="gl-pt-3 gl-px-3 gl-bg-gray-10 gl-display-flex gl-justify-content-end gl-align-items-center"
  >
    <gl-form-group label-size="sm">
      <gl-form-checkbox class="gl-mt-3" :checked="filterDismissed" @change="changeDismissedFilter"
        >{{ __('Hide dismissed alerts') }}
      </gl-form-checkbox>
    </gl-form-group>
  </div>
</template>
