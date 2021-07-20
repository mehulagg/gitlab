<script>
import { GlButton, GlDropdown, GlDropdownItem } from '@gitlab/ui';

const ANY_WEIGHT = 'Any weight';
const NO_WEIGHT = 'None';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
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
    selectWeight(weight) {
      // eslint-disable-next-line vue/no-mutating-props
      this.board.weight = this.weightInt(weight);
      this.dropdownHidden = true;
    },
    weightInt(weight) {
      if (weight >= 0) {
        return weight;
      } else if (weight === NO_WEIGHT) {
        return -2;
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
      <gl-button
        v-if="canEdit"
        variant="link"
        class="float-right gl-text-gray-800!"
        @click="showDropdown"
      >
        {{ __('Edit') }}
      </gl-button>
    </div>
    <div :class="valueClass" :hidden="!dropdownHidden" class="value">{{ valueText }}</div>

    <gl-dropdown
      ref="dropdown"
      :hidden="dropdownHidden"
      :text="valueText"
      block
      toggle-class="d-flex justify-content-between"
    >
      <gl-dropdown-item
        v-for="weight in weights"
        :key="weight"
        :value="weight"
        @click="selectWeight(weight)"
      >
        {{ weight }}
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
