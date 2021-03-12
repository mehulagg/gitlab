<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlDropdownSectionHeader,
  GlTooltipDirective,
  GlLoadingIcon,
} from '@gitlab/ui';
import { __ } from '~/locale';
import { iterationSelectTextMap, iterationDisplayState } from '../constants';
import groupIterationsQuery from '../queries/iterations.query.graphql';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlDropdownSectionHeader,
    GlLoadingIcon,
  },
  apollo: {
    iterations: {
      query: groupIterationsQuery,
      debounce: 250,
      variables() {
        const search = this.searchTerm ? `"${this.searchTerm}"` : '';

        return {
          fullPath: this.fullPath,
          title: search,
          state: iterationDisplayState,
        };
      },
      update(data) {
        // TODO: https://gitlab.com/gitlab-org/gitlab/-/issues/220379
        return data.group?.iterations?.nodes || [];
      },
      result({ data }) {
        const nodes = data.group?.iterations?.nodes || [];

        this.iterations = iterationSelectTextMap.noIterationItem.concat(nodes);
      },
      skip() {
        return !this.shouldFetch;
      },
    },
  },
  props: {
    fullPath: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      searchTerm: '',
      iterations: [],
      currentIteration: null,
      shouldFetch: false,
    };
  },
  computed: {
    title() {
      return this.currentIteration?.title || __('Select iteration');
    },
  },
  methods: {
    onClick(iteration) {
      if (iteration.id === this.currentIteration?.id) {
        this.currentIteration = null;
      } else {
        this.currentIteration = iteration;
      }

      this.$emit('onIterationSelect', this.currentIteration);
    },
    isIterationChecked(id) {
      return id === this.currentIteration?.id;
    },
    onDropdownShow() {
      this.shouldFetch = true;
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <gl-dropdown :text="title" class="gl-w-full" @show="onDropdownShow">
      <gl-dropdown-section-header class="gl-display-flex! gl-justify-content-center">{{
        __('Assign Iteration')
      }}</gl-dropdown-section-header>
      <gl-search-box-by-type v-model="searchTerm" />
      <gl-loading-icon v-if="$apollo.loading" />
      <gl-dropdown-item
        v-for="iterationItem in iterations"
        v-else
        :key="iterationItem.id"
        :is-check-item="true"
        :is-checked="isIterationChecked(iterationItem.id)"
        @click="onClick(iterationItem)"
        >{{ iterationItem.title }}</gl-dropdown-item
      >
    </gl-dropdown>
  </div>
</template>
