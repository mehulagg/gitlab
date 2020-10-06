<script>
import { GlDropdown, GlDropdownItem, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlIcon,
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
    <gl-dropdown-item v-for="button in buttons" :key="button.action" @click="setButton(button)">
      <div class="media">
        <div>
          <gl-icon v-if="selectedButton === button" class="gl-mr-2" name="mobile-issue-close" />
        </div>
        <div class="media-body" :class="{ 'prepend-left-20': selectedButton !== button }">
          <strong>{{ button.name }}</strong>
          <br />
          <span>{{ button.tagline }}</span>
        </div>
      </div>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
