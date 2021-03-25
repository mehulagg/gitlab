<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    approverTypeOptions: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      selected: null,
    };
  },
  computed: {
    dropdownText() {
      return this.selected.text;
    },
  },
  watch: {
    selected(option) {
      this.$emit('input', option.type);
    },
  },
  created() {
    const [firstOption] = this.approverTypeOptions;
    this.selected = firstOption;
  },
  methods: {
    isSelectedType(type) {
      return this.selected.type === type;
    },
    onSelect(option) {
      this.selected = option;
    },
  },
  dropdownClass: {
    'gl-w-full': true,
    'gl-dropdown-menu-full-width': true,
  },
};
</script>

<template>
  <gl-dropdown :class="$options.dropdownClass" :text="dropdownText">
    <gl-dropdown-item
      v-for="option in approverTypeOptions"
      :key="option.type"
      :is-check-item="true"
      :is-checked="isSelectedType(option.type)"
      @click="onSelect(option)"
    >
      <span>{{ option.text }}</span>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
