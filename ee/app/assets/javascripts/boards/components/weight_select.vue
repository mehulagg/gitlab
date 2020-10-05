<script>
import { GlButton, GlDeprecatedDropdown, GlDeprecatedDropdownItem } from '@gitlab/ui';

const ANY_WEIGHT = 'Any weight';
const NO_WEIGHT = 'None';

export default {
  components: {
    GlButton,
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
  },
  props: {
    board: {
      type: Object,
      required: true,
    },
    canEdit: {
      type: Boolean,
      required: false,
      default: false,
    },
    weights: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      dropdownHidden: true,
    };
  },
  computed: {
    valueClass() {
      if (this.valueText === ANY_WEIGHT) {
        return 'text-secondary';
      }
      return 'bold';
    },
    valueText() {
      const { weight } = this.board;
      if (weight > 0 || weight === 0) return weight.toString();
      if (weight === -2) return NO_WEIGHT;
      return ANY_WEIGHT;
    },
  },
  methods: {
    showDropdown() {
      this.dropdownHidden = false;
      this.$refs.dropdown.$children[0].show();
    },
    selectWeight({ target: { value: weight } }) {
      this.board.weight = this.weightInt(weight);
      this.dropdownHidden = true;
    },
    weightInt(weight) {
      if (weight > 0) {
        return parseInt(weight, 10);
      } else if (weight === NO_WEIGHT) {
        return -2;
      } else if (weight === '0') {
        return 0;
      }
      return -1;
    },
  },
};
</script>

<template>
  <div class="block weight">
    <div class="title gl-mb-3">
      {{ __('Weight') }}
      <gl-button v-if="canEdit" variant="link" class="float-right" @click="showDropdown">
        {{ __('Edit') }}
      </gl-button>
    </div>
    <div :class="valueClass" :hidden="!dropdownHidden" class="value">{{ valueText }}</div>

    <gl-deprecated-dropdown
      ref="dropdown"
      :hidden="dropdownHidden"
      :text="valueText"
      class="w-100"
      menu-class="w-100"
      toggle-class="d-flex justify-content-between"
    >
      <div ref="weight-select" @click="selectWeight">
        <gl-deprecated-dropdown-item v-for="weight in weights" :key="weight" :value="weight">
          {{ weight }}
        </gl-deprecated-dropdown-item>
      </div>
    </gl-deprecated-dropdown>
  </div>
</template>
