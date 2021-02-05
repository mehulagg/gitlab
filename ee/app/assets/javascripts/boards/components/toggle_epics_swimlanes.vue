<script>
import { mapState, mapActions } from 'vuex';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { __ } from '~/locale';
import Tracking from '~/tracking';

const trackingMixin = Tracking.mixin();

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  mixins: [trackingMixin],
  computed: {
    ...mapState(['isShowingEpicsSwimlanes']),

    groupByEpicLabel() {
      return __('Epic');
    },
    groupByNoneLabel() {
      return __('No grouping');
    },
    dropdownLabel() {
      return this.isShowingEpicsSwimlanes ? this.groupByEpicLabel : __('None');
    },
  },
  methods: {
    ...mapActions(['toggleEpicSwimlanes']),

    onToggle() {
      // Track toggle event
      this.track('click_toggle_swimlanes_button', {
        label: 'toggle_swimlanes',
        property: this.isShowingEpicsSwimlanes ? 'off' : 'on',
      });

      // Track if the board has swimlane active
      if (!this.isShowingEpicsSwimlanes) {
        this.track('click_toggle_swimlanes_button', {
          label: 'swimlanes_active',
        });
      }

      this.toggleEpicSwimlanes();
    },
  },
};
</script>

<template>
  <div
    class="board-swimlanes-toggle-wrapper gl-md-display-flex gl-align-items-center gl-ml-3"
    data-testid="toggle-swimlanes"
  >
    <span
      class="board-swimlanes-toggle-text gl-white-space-nowrap gl-font-weight-bold"
      data-testid="toggle-swimlanes-label"
    >
      {{ __('Group by') }}
    </span>
    <gl-dropdown
      right
      :text="dropdownLabel"
      toggle-class="gl-ml-3 gl-border-none gl-inset-border-1-gray-200! border-radius-default"
    >
      <gl-dropdown-item
        :is-check-item="true"
        :is-checked="!isShowingEpicsSwimlanes"
        @click="onToggle()"
        >{{ groupByNoneLabel }}</gl-dropdown-item
      >
      <gl-dropdown-item
        :is-check-item="true"
        :is-checked="isShowingEpicsSwimlanes"
        @click="onToggle()"
        >{{ groupByEpicLabel }}</gl-dropdown-item
      >
    </gl-dropdown>
  </div>
</template>
