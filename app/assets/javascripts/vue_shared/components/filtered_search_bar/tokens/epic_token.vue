<script>
import {
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlDropdownDivider,
  GlLoadingIcon,
} from '@gitlab/ui';
import { debounce } from 'lodash';

import createFlash from '~/flash';
import { __ } from '~/locale';

import { DEFAULT_EPICS, DEBOUNCE_DELAY } from '../constants';
import { stripQuotes } from '../filtered_search_utils';

export default {
  components: {
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlDropdownDivider,
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
      epics: this.config.initialEpics || [],
      defaultEpics: this.config.defaultEpics || DEFAULT_EPICS,
      loading: true,
    };
  },
  computed: {
    currentValue() {
      return this.value.data.toLowerCase();
    },
    activeEpic() {
      return this.epics.find((epic) => epic.title.toLowerCase() === this.currentValue);
    },
  },
  watch: {
    active: {
      immediate: true,
      handler(newValue) {
        if (!newValue && !this.epics.length) {
          this.fetchEpicsBySearchTerm(this.value.data);
        }
      },
    },
  },
  methods: {
    fetchEpicsBySearchTerm(searchTerm = '') {
      this.loading = true;
      this.config
        .fetchEpics(searchTerm)
        .then(({ data }) => {
          this.epics = data;
        })
        .catch(() => createFlash({ message: __('There was a problem fetching epics.') }))
        .finally(() => {
          this.loading = false;
        });
    },
    searchEpics: debounce(function debouncedSearch({ data }) {
      this.fetchEpicsBySearchTerm(data);
    }, DEBOUNCE_DELAY),
  },
};
</script>

<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="searchEpics"
  >
    <template #view="{ inputValue }">
      <span>&{{ activeEpic ? activeEpic.title : inputValue }}</span>
    </template>
    <template #suggestions>
      <gl-filtered-search-suggestion
        v-for="epic in defaultEpics"
        :key="epic.value"
        :value="epic.value"
      >
        {{ epic.text }}
      </gl-filtered-search-suggestion>
      <gl-dropdown-divider v-if="defaultEpics.length" />
      <gl-loading-icon v-if="loading" />
      <template v-else>
        <gl-filtered-search-suggestion v-for="epic in epics" :key="epic.id" :value="epic.title">
          <div>{{ epic.title }}</div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
