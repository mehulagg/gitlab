<script>
import {
  GlIcon,
  GlButton,
  GlLoadingIcon,
  GlTooltipDirective as GlTooltip,
  GlDropdownItem,
  GlDropdown,
  GlDropdownDivider,
} from '@gitlab/ui';
import Tracking from '~/tracking';
import { s__ } from '~/locale';
import { healthStatusTextMap } from '../../constants';

export default {
  directives: {
    GlTooltip,
  },
  components: {
    GlIcon,
    GlButton,
    GlLoadingIcon,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
  },
  mixins: [Tracking.mixin()],
  props: {
    isOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
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
    canRemoveStatus() {
      return this.isEditable && this.status;
    },
    statusText() {
      return this.status ? healthStatusTextMap[this.status] : s__('Sidebar|None');
    },
    dropdownText() {
      return this.status ? healthStatusTextMap[this.status] : s__('Select health status');
    },
    statusTooltip() {
      let tooltipText = s__('Sidebar|Health status');

      if (this.status) {
        tooltipText += `: ${this.statusText}`;
      }

      return {
        title: tooltipText,
      };
    },
    editTooltip() {
      const tooltipText = !this.isOpen
        ? s__('Health status cannot be edited because this issue is closed')
        : '';

      return {
        title: tooltipText,
        offset: -80,
      };
    },
  },
  watch: {
    status(status) {
      this.selectedStatus = status;
    },
  },
  mounted() {
    document.addEventListener('click', this.handleOffClick);
  },
  beforeDestroy() {
    document.removeEventListener('click', this.handleOffClick);
  },
  methods: {
    handleDropdownClick(status) {
      this.selectedStatus = status;
      this.$emit('onDropdownClick', status);
      this.track('change_health_status', { property: status });
      this.hideDropdown();
    },
    hideDropdown() {
      this.isDropdownShowing = false;
    },
    toggleFormDropdown() {
      this.isDropdownShowing = !this.isDropdownShowing;

      /**
       * We need to programmatically open the dropdown to make the
       * outside click on document close the dropdown.
       */
      const { dropdown } = this.$refs.dropdown.$refs;

      if (dropdown && !this.isDropdownShowing) {
        dropdown.show();
      }
    },
    removeStatus() {
      this.handleDropdownClick(null);
    },
    isSelected(status) {
      return this.status === status;
    },
    handleOffClick(event) {
      if (!this.isDropdownShowing) return;

      if (!this.$refs.dropdown.$el.contains(event.target)) {
        this.toggleFormDropdown();
      }
    },
  },
};
</script>

<template>
  <div class="block health-status">
    <div ref="status" v-gl-tooltip.left.viewport="statusTooltip" class="sidebar-collapsed-icon">
      <gl-icon name="status-health" :size="14" />

      <gl-loading-icon v-if="isFetching" />
      <p v-else class="collapse-truncated-title gl-px-2">{{ statusText }}</p>
    </div>

    <div class="hide-collapsed">
      <p class="title gl-display-flex justify-content-between">
        <span data-testid="statusTitle">{{ s__('Sidebar|Health status') }}</span>
        <span
          v-if="isEditable"
          v-gl-tooltip.topleft="editTooltip"
          data-testid="editButtonTooltip"
          tabindex="0"
        >
          <gl-button
            ref="editButton"
            variant="link"
            class="edit-link btn-link-hover gl-text-black-normal!"
            :disabled="!isOpen"
            @click.stop="toggleFormDropdown"
            @keydown.esc="hideDropdown"
          >
            {{ __('Edit') }}
          </gl-button>
        </span>
      </p>

      <div
        data-testid="dropdownWrapper"
        class="dropdown dropdown-menu-selectable"
        :class="{ show: isDropdownShowing, 'gl-display-none': !isDropdownShowing }"
      >
        <gl-dropdown
          ref="dropdown"
          class="gl-w-full"
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
            <gl-dropdown-item @click="handleDropdownClick(null)">
              <gl-button
                variant="link"
                class="dropdown-item health-dropdown-item gl-px-8!"
                :class="{ 'is-active': isSelected(null) }"
              >
                {{ s__('Sidebar|No status') }}
              </gl-button>
            </gl-dropdown-item>

            <gl-dropdown-divider class="divider health-divider" />

            <gl-dropdown-item
              v-for="option in statusOptions"
              :key="option.key"
              @click="handleDropdownClick(option.key)"
            >
              <gl-button
                variant="link"
                class="dropdown-item health-dropdown-item gl-px-8!"
                :class="{ 'is-active': isSelected(option.key) }"
              >
                {{ option.value }}
              </gl-button>
            </gl-dropdown-item>
          </div>
        </gl-dropdown>
      </div>

      <gl-loading-icon v-if="isFetching" :inline="true" />
      <p v-else-if="!isDropdownShowing" class="value gl-m-0" :class="{ 'no-value': !status }">
        <span v-if="status" class="text-plain gl-font-weight-bold">{{ statusText }}</span>
        <span v-else>{{ __('None') }}</span>
      </p>
    </div>
  </div>
</template>
