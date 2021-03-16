<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { __ } from '~/locale';
import { STAGE_VIEW, LAYER_VIEW } from './constants';

export default {
  name: 'GraphViewSelector',
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    type: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      currentViewType: STAGE_VIEW,
    };
  },
  i18n: {
    dropdownText: {
      [STAGE_VIEW]: __('Stage'),
      [LAYER_VIEW]: __('Needs relationships'),
    },
    labelText: __('Order jobs by'),
  },
  views: {
    [STAGE_VIEW]: {
      type: STAGE_VIEW,
      text: {
        primary: __('Stage'),
        secondary: __('View the jobs grouped into stages'),
      },
    },
    [LAYER_VIEW]: {
      type: LAYER_VIEW,
      text: {
        primary: __('Needs relationships'),
        secondary: __('View what jobs are needed for a job to run'),
      },
    },
  },
  computed: {
    currentDropdownText() {
      return this.$options.views[this.type].text.primary;
    },
  },
  methods: {
    itemClick(type) {
      this.$emit('updateViewType', type);
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-end gl-align-items-center">
    <span>{{ $options.i18n.labelText }}</span>
    <gl-dropdown class="gl-ml-4" :text="currentDropdownText" :right="true">
      <gl-dropdown-item
        v-for="view in $options.views"
        :key="view.type"
        :secondary-text="view.text.secondary"
        @click="itemClick(view.type)"
      >
        {{ view.text.primary }}
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
