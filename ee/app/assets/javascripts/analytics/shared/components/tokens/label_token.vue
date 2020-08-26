<script>
import {
  GlToken,
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlDeprecatedDropdownDivider,
  GlLoadingIcon,
} from '@gitlab/ui';
import { debounce } from 'lodash';
import { __ } from '~/locale';
import { DEBOUNCE_DELAY } from '~/vue_shared/components/filtered_search_bar/constants';

export default {
  components: {
    GlToken,
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlDeprecatedDropdownDivider,
    GlLoadingIcon,
  },
  inheritAttrs: false,
  props: {
    config: {
      type: Object,
      required: true,
    },
    value: {
      type: Object,
      required: true,
    },
    active: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      activeLabel: null,
    };
  },
  computed: {
    labels() {
      return this.config.labels;
    },
    containerStyle() {
      if (this.activeLabel) {
        const { color, text_color } = this.activeLabel;

        return { backgroundColor: color, color: text_color };
      }

      return {};
    },
  },
  watch: {
    active: {
      immediate: true,
      handler(newValue) {
        if (!newValue && this.labels) {
          this.activeLabel = this.labels.find(l => l.title === this.value?.data);
        }
      },
    },
  },
  created() {
    this.searchLabels(this.value);
  },
  methods: {
    searchLabels: debounce(function debouncedSearch({ data = '' }) {
      this.config.fetchData(data);
    }, DEBOUNCE_DELAY),
  },
  defaultSuggestions: [
    // eslint-disable-next-line @gitlab/require-i18n-strings
    { value: 'None', text: __('None') },
    // eslint-disable-next-line @gitlab/require-i18n-strings
    { value: 'Any', text: __('Any') },
  ],

  emits: [],
};
</script>

<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="searchLabels"
  >
    <template #view-token="{ inputValue, cssClasses, listeners }">
      <gl-token
        variant="search-value"
        :class="cssClasses"
        :style="containerStyle"
        data-testid="selected-label"
        v-on="listeners"
      >
        <template v-if="config.symbol">{{ config.symbol }}</template>
        {{ activeLabel ? activeLabel.title : inputValue }}
      </gl-token>
    </template>
    <template #suggestions>
      <gl-loading-icon v-if="config.isLoading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="suggestion in $options.defaultSuggestions"
          :key="suggestion.value"
          :value="suggestion.value"
          >{{ suggestion.text }}</gl-filtered-search-suggestion
        >
        <gl-deprecated-dropdown-divider v-if="config.isLoading || labels.length" />
        <gl-filtered-search-suggestion
          v-for="label in labels"
          ref="labelItem"
          :key="label.id"
          :value="label.title"
        >
          <div class="d-flex">
            <span
              class="d-inline-block mr-2 gl-w-16 gl-h-16 border-radius-small"
              :style="{
                backgroundColor: label.color,
              }"
            ></span>
            <span>{{ label.title }}</span>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
