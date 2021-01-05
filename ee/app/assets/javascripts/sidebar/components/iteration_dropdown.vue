<script>
import {
  GlButton,
  GlLink,
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlDropdownSectionHeader,
  GlIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import groupIterationsQuery from '../queries/group_iterations.query.graphql';
import currentIterationQuery from '../queries/issue_iteration.query.graphql';
import setIssueIterationMutation from '../queries/set_iteration_on_issue.mutation.graphql';
import { iterationSelectTextMap, iterationDisplayState } from '../constants';
import { deprecatedCreateFlash as createFlash } from '~/flash';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlDropdownSectionHeader,
  },
  apollo: {
    iterations: {
      query: groupIterationsQuery,
      debounce: 250,
      variables() {
        // TODO: https://gitlab.com/gitlab-org/gitlab/-/issues/220381
        const search = this.searchTerm === '' ? '' : `"${this.searchTerm}"`;

        return {
          fullPath: this.groupPath,
          title: search,
          state: iterationDisplayState,
        };
      },
      update(data) {
        // TODO: https://gitlab.com/gitlab-org/gitlab/-/issues/220379
        const nodes = data.group?.iterations?.nodes || [];

        return iterationSelectTextMap.noIterationItem.concat(nodes);
      },
    },
  },
  data() {
    return {
      searchTerm: '',
      iterations: iterationSelectTextMap.noIterationItem,
    };
  },
  methods: {
    isIterationChecked(iterationId = undefined) {
      return (
        iterationId === this.currentIteration?.id || (!this.currentIteration?.id && !iterationId)
      );
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <gl-dropdown
      :text="$options.iterationText"
      class="dropdown gl-w-full"
      :class="{ show: editing }"
    >
      <gl-dropdown-section-header class="d-flex justify-content-center">{{
        __('Assign Iteration')
      }}</gl-dropdown-section-header>
      <gl-search-box-by-type ref="search" v-model="searchTerm" />
      <gl-dropdown-item
        v-for="iterationItem in iterations"
        :key="iterationItem.id"
        :is-check-item="true"
        :is-checked="isIterationChecked(iterationItem.id)"
        @click="setIteration(iterationItem.id)"
        >{{ iterationItem.title }}</gl-dropdown-item
      >
    </gl-dropdown>
  </div>
</template>
