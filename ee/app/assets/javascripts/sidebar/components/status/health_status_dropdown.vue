<script>
import {
  GlButton,
  GlDropdownItem,
  GlDropdown,
  GlDropdownDivider,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { healthStatusTextMap } from '../../constants';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
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
    dropdownHeaderText() {
      return s__('Sidebar|Assign health status');
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
  <div class="dropdown">
    <gl-dropdown
      ref="dropdown"
      class="gl-w-full"
      :header-text="dropdownHeaderText"
      :text="dropdownText"
      @keydown.esc.native="hideDropdown"
      @hide="hideDropdown"
    >
      <gl-dropdown-item 
        :is-check-item="true"
        :is-checked="isSelected(null)"
        @click="handleDropdownClick(null)"
      >
        {{ s__('Sidebar|No status') }}
      </gl-dropdown-item>

        <gl-dropdown-divider />

        <gl-dropdown-item
          v-for="option in statusOptions"
          :key="option.key"
          :is-check-item="true"
          :is-checked="isSelected(option.key)"
          @click="handleDropdownClick(option.key)"
        >
          {{ option.value }}
        </gl-dropdown-item>
      </div>
    </gl-dropdown>
  </div>
</template>
