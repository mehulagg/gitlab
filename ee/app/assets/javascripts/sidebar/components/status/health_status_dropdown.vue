<script>
import {
  GlButton,
  GlDeprecatedDropdownItem,
  GlDeprecatedDropdown,
  GlDeprecatedDropdownDivider,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { healthStatusTextMap } from '../../constants';

export default {
  components: {
    GlButton,
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
    GlDeprecatedDropdownDivider,
  },
  props: {
    isEditable: {
      type: Boolean,
      required: false,
      default: false,
    },
    isFetching: {
      type: Boolean,
      required: false,
      default: false,
    },
    status: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isDropdownShowing: false,
      selectedStatus: this.status,
      statusOptions: Object.keys(healthStatusTextMap).map((key) => ({
        key,
        value: healthStatusTextMap[key],
      })),
    };
  },
  computed: {
    statusText() {
      return this.status ? healthStatusTextMap[this.status] : s__('Sidebar|None');
    },
    dropdownText() {
      if (this.status === null) {
        return s__('No status');
      }

      return this.status ? healthStatusTextMap[this.status] : s__('Select health status');
    },
    tooltipText() {
      let tooltipText = s__('Sidebar|Health status');

      if (this.status) {
        tooltipText += `: ${this.statusText}`;
      }

      return tooltipText;
    },
  },
  watch: {
    status(status) {
      this.selectedStatus = status;
    },
  },
  methods: {
    handleDropdownClick(status) {
      this.selectedStatus = status;
      this.$emit('onDropdownClick', status);
      this.hideDropdown();
    },
    hideDropdown() {
      this.isDropdownShowing = false;
    },
    isSelected(status) {
      return this.status === status;
    },
  },
};
</script>

<template>
  <div class="dropdown dropdown-menu-selectable">
    <gl-deprecated-dropdown
      ref="dropdown"
      class="w-100"
      :text="dropdownText"
      @keydown.esc.native="hideDropdown"
      @hide="hideDropdown"
    >
      <div class="dropdown-title gl-display-flex">
        <span class="health-title gl-ml-auto">{{ s__('Sidebar|Assign health status') }}</span>
        <gl-button
          :aria-label="__('Close')"
          variant="link"
          class="dropdown-title-button dropdown-menu-close gl-ml-auto gl-text-gray-200!"
          icon="close"
          @click="hideDropdown"
        />
      </div>

      <div class="dropdown-content dropdown-body">
        <gl-deprecated-dropdown-item @click="handleDropdownClick(null)">
          <gl-button
            variant="link"
            class="dropdown-item health-dropdown-item"
            :class="{ 'is-active': isSelected(null) }"
          >
            {{ s__('Sidebar|No status') }}
          </gl-button>
        </gl-deprecated-dropdown-item>

        <gl-deprecated-dropdown-divider class="divider health-divider" />

        <gl-deprecated-dropdown-item
          v-for="option in statusOptions"
          :key="option.key"
          @click="handleDropdownClick(option.key)"
        >
          <gl-button
            variant="link"
            class="dropdown-item health-dropdown-item"
            :class="{ 'is-active': isSelected(option.key) }"
          >
            {{ option.value }}
          </gl-button>
        </gl-deprecated-dropdown-item>
      </div>
    </gl-deprecated-dropdown>
  </div>
</template>
