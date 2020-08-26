<script>
import { GlNewDropdown, GlNewDropdownItem } from '@gitlab/ui';

export default {
  components: {
    GlNewDropdown,
    GlNewDropdownItem,
  },
  props: {
    visibilityLevelOptions: {
      type: Array,
      required: true,
    },
    defaultLevel: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      selectedOption: this.getDefaultOption(),
    };
  },
  methods: {
    getDefaultOption() {
      return this.visibilityLevelOptions.find(option => option.level === this.defaultLevel);
    },
    onClick(option) {
      this.selectedOption = option;
    },
  },

  emits: [],
};
</script>
<template>
  <div>
    <input type="hidden" name="group[visibility_level]" :value="selectedOption.level" />
    <gl-new-dropdown :text="selectedOption.label" class="gl-w-full" menu-class="gl-w-full! gl-mb-0">
      <gl-new-dropdown-item
        v-for="option in visibilityLevelOptions"
        :key="option.level"
        :secondary-text="option.description"
        @click="onClick(option)"
      >
        <div class="gl-font-weight-bold gl-mb-1">{{ option.label }}</div>
      </gl-new-dropdown-item>
    </gl-new-dropdown>
  </div>
</template>
