<script>
import {
  GlToken,
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlLoadingIcon,
} from '@gitlab/ui';
import { stripQuotes } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import GroupLabelsQuery from '../graphql/group_labels.query.graphql';

export default {
  components: {
    GlToken,
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
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
  apollo: {
    labels: {
      query: GroupLabelsQuery,
      debounce: 250,
      variables() {
        return {
          fullPath: this.config.fullPath,
          search: this.search,
        };
      },
      update(data) {
        return data.group?.labels?.edges.map((item) => item.node) || [];
      },
    },
  },
  data() {
    return {
      labels: [],
      search: '', // on page load if this is there
    };
  },
  computed: {
    currentValue() {
      return this.value.data.toLowerCase();
    },
    activeLabel() {
      return this.labels.find(
        (label) => label.title.toLowerCase() === stripQuotes(this.currentValue),
      );
    },
    containerStyle() {
      if (this.activeLabel) {
        const { color, textColor } = this.activeLabel;

        return { backgroundColor: color, color: textColor };
      }
      return {};
    },
  },
  methods: {
    searchForToken(searchTerm) {
      this.search = searchTerm?.data;
    },
  },
};
</script>

<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="searchForToken"
  >
    <template #view-token="{ inputValue, cssClasses, listeners }">
      <gl-token variant="search-value" :class="cssClasses" :style="containerStyle" v-on="listeners"
        >~{{ activeLabel ? activeLabel.title : inputValue }}</gl-token
      >
    </template>
    <template #suggestions>
      <gl-loading-icon v-if="$apollo.loading" />
      <template v-else>
        <gl-filtered-search-suggestion v-for="label in labels" :key="label.id" :value="label.title">
          <div class="gl-display-flex">
            <span
              :style="{ backgroundColor: label.color }"
              class="gl-display-inline-block mr-2 p-2"
            ></span>
            <div>{{ label.title }}</div>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
