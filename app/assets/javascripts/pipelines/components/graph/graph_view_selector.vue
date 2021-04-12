<script>
import { GlLoadingIcon, GlSegmentedControl, GlToggle } from '@gitlab/ui';
import { __ } from '~/locale';
import { STAGE_VIEW, LAYER_VIEW } from './constants';

export default {
  name: 'GraphViewSelector',
  components: {
    GlLoadingIcon,
    GlSegmentedControl,
    GlToggle,
  },
  props: {
    linksLoading: {
      type: Boolean,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      currentViewType: this.type,
      showLinks: false,
      isToggleLoading: false,
      isSwitcherLoading: false,
    };
  },
  i18n: {
    viewLabelText: __('Group jobs by'),
    linksLabelText: __('Show dependencies'),
  },
  views: {
    [STAGE_VIEW]: {
      type: STAGE_VIEW,
      text: {
        primary: __('Stage'),
        secondary: __('Group jobs into stages'),
      },
    },
    [LAYER_VIEW]: {
      type: LAYER_VIEW,
      text: {
        primary: __('Job dependencies'),
        secondary: __('Group jobs by configured dependencies'),
      },
    },
  },
  computed: {
    showLinksToggle() {
      return this.currentViewType === LAYER_VIEW;
    },
    viewTypesList() {
      return Object.keys(this.$options.views).map((key) => {
        return {
          value: key,
          text: this.$options.views[key].text.primary,
        };
      });
    },
  },
  watch: {
    linksLoading() {
      this.isToggleLoading = false;
    },
    type() {
      this.isSwitcherLoading = false;
    },
  },
  methods: {
    toggleView(type) {
      this.isSwitcherLoading = true;
      setTimeout(() => {
        this.$emit('updateViewType', type);
      });
    },
    toggleLoading(val) {
      this.isToggleLoading = true;
      setTimeout(() => {
        this.$emit('updateShowLinks', val);
      });
    },
  },
};
</script>

<template>
  <div class="gl-relative gl-display-flex gl-align-items-center gl-w-max-content gl-my-4">
    <gl-loading-icon
      v-if="isSwitcherLoading"
      class="gl-absolute gl-w-full gl-bg-white gl-opacity-5 gl-z-index-2"
      size="lg"
    />
    <span class="gl-font-weight-bold">{{ $options.i18n.viewLabelText }}</span>
    <gl-segmented-control
      v-model="currentViewType"
      :options="viewTypesList"
      :disabled="isSwitcherLoading"
      data-testid="pipeline-view-selector"
      class="gl-mx-4"
      @input="toggleView"
    />

    <div v-if="showLinksToggle">
      <gl-toggle
        v-model="showLinks"
        class="gl-mx-4"
        :label="$options.i18n.linksLabelText"
        :is-loading="isToggleLoading"
        label-position="left"
        @change="toggleLoading"
      />
    </div>
  </div>
</template>
