<script>
import {
  GlToken,
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlDropdownDivider,
  GlLoadingIcon,
} from '@gitlab/ui';
import { debounce } from 'lodash';

import { deprecatedCreateFlash as createFlash } from '~/flash';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

import GroupLabelsQuery from '../graphql/group_labels.query.graphql';
import { stripQuotes } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';

export default {
  components: {
    GlToken,
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
  apollo: {
    // might be able to do this with renderless slots
    // think we are going to use no-cache as a fetch policy or network-only https://www.apollographql.com/docs/react/data/queries/
    labels: {
      query: GroupLabelsQuery,
      variables() {
        return {
          fullPath: 'h5bp', // TODO: get this
        };
      },
      update(data) {
        return data.group.labels.edges.map((item) => item.node);
      },
    },
  },
  data() {
    return {
      labels: [],
      defaultLabels: [],
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
};
</script>

<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="() => {}"
  >
    <template #view-token="{ inputValue, cssClasses, listeners }">
      <gl-token variant="search-value" :class="cssClasses" :style="containerStyle" v-on="listeners"
        >~{{ activeLabel ? activeLabel.title : inputValue }}</gl-token
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
      <gl-dropdown-divider v-if="defaultLabels.length" />
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
