<script>
import { GlDeprecatedDropdown, GlDeprecatedDropdownItem, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
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
  <gl-deprecated-dropdown
    v-if="selectedButton"
    :disabled="disabled"
    no-caret
    right
    split
    variant="success"
    :text="selectedButton.name"
    @click="handleClick"
  >
    <gl-deprecated-dropdown-item
      v-for="button in buttons"
      :key="button.action"
      @click="setButton(button)"
    >
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
    </gl-deprecated-dropdown-item>
  </gl-deprecated-dropdown>
</template>
