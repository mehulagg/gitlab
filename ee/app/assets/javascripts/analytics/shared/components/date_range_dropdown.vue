<script>
import { GlDeprecatedDropdown, GlDeprecatedDropdownItem } from '@gitlab/ui';
import { __, sprintf } from '~/locale';

export default {
  components: {
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
  },
  props: {
    availableDaysInPast: {
      type: Array,
      required: false,
      default: () => [7, 14, 30, 60, 90, 120],
    },
    defaultSelected: {
      type: Number,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      selected: this.defaultSelected,
    };
  },
  computed: {
    dropdownText() {
      return this.selected && this.availableDaysInPast.indexOf(this.selected) !== -1
        ? this.getLabel(this.selected)
        : __('Select timeframe');
    },
  },
  methods: {
    onSelect(days) {
      this.selected = days;
      this.$emit('selected', days);
    },
    getLabel(days) {
      return sprintf(__('Last %{days} days'), { days });
    },
  },
};
</script>
<template>
  <gl-deprecated-dropdown
    toggle-class="dropdown-menu-toggle w-100"
    menu-class="w-100 mw-100"
    :text="dropdownText"
  >
    <gl-deprecated-dropdown-item
      v-for="d in availableDaysInPast"
      :key="d"
      class="w-100"
      @click="onSelect(d)"
      >{{ getLabel(d) }}</gl-deprecated-dropdown-item
    >
  </gl-deprecated-dropdown>
</template>
