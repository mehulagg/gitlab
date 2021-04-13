<script>
import {
  GlToken,
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlDropdownDivider,
  GlDropdownSectionHeader,
  GlLoadingIcon,
} from '@gitlab/ui';
import { uniqWith, isEqual } from 'lodash';

import { deprecatedCreateFlash as createFlash } from '~/flash';
import AccessorUtilities from '~/lib/utils/accessor';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

import { DEFAULT_LABELS, DEBOUNCE_DELAY, MAX_RECENT_TOKENS_SIZE } from '../constants';
import { stripQuotes } from '../filtered_search_utils';

export default {
  components: {
    GlToken,
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlDropdownDivider,
    GlDropdownSectionHeader,
    GlLoadingIcon,
  },
  props: {
    config: {
      type: Object,
      required: true,
    },
    value: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      searchKey: '',
      labels: this.config.initialLabels || [],
      recentLabels: [],
      defaultLabels: this.config.defaultLabels || DEFAULT_LABELS,
      loading: true,
    };
  },
  computed: {
    isRecentLabelsEnabled() {
      return Boolean(
        this.config.recentTokenValuesStorageKey && AccessorUtilities.isLocalStorageAccessSafe(),
      );
    },
    currentValue() {
      return this.value.data.toLowerCase();
    },
    activeLabel() {
      return this.labels.find(
        (label) => this.getLabelName(label).toLowerCase() === stripQuotes(this.currentValue),
      );
    },
    containerStyle() {
      if (this.activeLabel) {
        const { color, textColor } = convertObjectPropsToCamelCase(this.activeLabel);

        return { backgroundColor: color, color: textColor };
      }
      return {};
    },
    availableRecentLabels() {
      return this.recentLabels.filter((label) =>
        this.getLabelName(label).toLowerCase().includes(this.searchKey.toLowerCase()),
      );
    },
  },
  watch: {
    active: {
      immediate: true,
      handler(newValue) {
        if (!newValue && !this.labels.length) {
          this.fetchLabelBySearchTerm(this.value.data);
        }
      },
    },
  },
  mounted() {
    if (this.isRecentLabelsEnabled) this.populateRecentLabels();
  },
  methods: {
    /**
     * There's an inconsistency between private and public API
     * for labels where label name is included in a different
     * property;
     *
     * Private API => `label.title`
     * Public API => `label.name`
     *
     * This method allows compatibility as there may be instances
     * where `config.fetchLabels` provided externally may still be
     * using either of the two APIs.
     */
    getLabelName(label) {
      return label.name || label.title;
    },
    populateRecentLabels() {
      this.recentLabels =
        JSON.parse(localStorage.getItem(this.config.recentTokenValuesStorageKey)) || [];
    },
    fetchLabelBySearchTerm(searchTerm) {
      this.loading = true;
      this.config
        .fetchLabels(searchTerm)
        .then((res) => {
          // We'd want to avoid doing this check but
          // labels.json and /groups/:id/labels & /projects/:id/labels
          // return response differently.
          this.labels = Array.isArray(res) ? res : res.data;
        })
        .catch(() => createFlash(__('There was a problem fetching labels.')))
        .finally(() => {
          this.loading = false;
        });
    },
    searchLabels({ data }) {
      this.searchKey = data;
      setTimeout(() => {
        if (!this.loading) this.fetchLabelBySearchTerm(data);
      }, DEBOUNCE_DELAY);
    },
    handleLabelSelected() {
      if (this.isRecentLabelsEnabled) {
        const recentLabels =
          JSON.parse(localStorage.getItem(this.config.recentTokenValuesStorageKey)) || [];

        recentLabels.splice(0, 0, { ...this.activeLabel });

        localStorage.setItem(
          this.config.recentTokenValuesStorageKey,
          JSON.stringify(uniqWith(recentLabels, isEqual).slice(0, MAX_RECENT_TOKENS_SIZE)),
        );
      }
    },
  },
};
</script>

<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="searchLabels"
    @select="handleLabelSelected"
  >
    <template #view-token="{ inputValue, cssClasses, listeners }">
      <gl-token variant="search-value" :class="cssClasses" :style="containerStyle" v-on="listeners"
        >~{{ activeLabel ? getLabelName(activeLabel) : inputValue }}</gl-token
      >
    </template>
    <template #suggestions>
      <gl-filtered-search-suggestion
        v-for="label in defaultLabels"
        :key="label.value"
        :value="label.value"
      >
        {{ label.text }}
      </gl-filtered-search-suggestion>
      <gl-dropdown-divider v-if="availableRecentLabels.length" />
      <template v-if="config.recentTokenValuesStorageKey && availableRecentLabels.length">
        <gl-dropdown-section-header>{{ __('Recent Labels') }}</gl-dropdown-section-header>
        <gl-filtered-search-suggestion
          v-for="label in availableRecentLabels"
          :key="`recent-${label.id}`"
          :value="getLabelName(label)"
        >
          <div class="gl-display-flex gl-align-items-center">
            <span
              :style="{ backgroundColor: label.color }"
              class="gl-display-inline-block mr-2 p-2"
            ></span>
            <div>{{ getLabelName(label) }}</div>
          </div>
        </gl-filtered-search-suggestion>
      </template>
      <gl-dropdown-divider v-if="defaultLabels.length" />
      <gl-loading-icon v-if="loading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="label in labels"
          :key="label.id"
          :value="getLabelName(label)"
        >
          <div class="gl-display-flex gl-align-items-center">
            <span
              :style="{ backgroundColor: label.color }"
              class="gl-display-inline-block mr-2 p-2"
            ></span>
            <div>{{ getLabelName(label) }}</div>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
