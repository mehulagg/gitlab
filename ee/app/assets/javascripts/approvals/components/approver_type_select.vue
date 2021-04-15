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
  created() {
    const [firstOption] = this.approverTypeOptions;
    this.onSelect(firstOption);
  },
  methods: {
    isSelectedType(type) {
      return this.selected.type === type;
    },
    onSelect(option) {
      this.selected = option;
      this.$emit('input', option.type);
    },
  },
};
</script>

<template>
  <gl-dropdown class="gl-w-full gl-dropdown-menu-full-width" :text="dropdownText">
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
