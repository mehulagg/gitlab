<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    buttons: {
      type: Array,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data: () => ({
    selectedButton: {},
  }),
  created() {
    this.setButton(this.buttons[0]);
  },
  methods: {
    setButton(button) {
      this.selectedButton = button;
    },
    handleClick() {
      this.$emit(this.selectedButton.action);
    },
  },
};
</script>

<template>
  <gl-dropdown
    v-if="selectedButton"
    :disabled="disabled"
    variant="success"
    category="secondary"
    toggle-class="btn-success-secondary"
    :text="selectedButton.name"
    @click="handleClick"
  >
    <gl-dropdown-item
      v-for="button in buttons"
      :key="button.action"
      :is-checked="selectedButton === button"
      is-check-item
      @click="setButton(button)"
    >
      <strong>{{ button.name }}</strong>
      <br />
      <span>{{ button.tagline }}</span>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
