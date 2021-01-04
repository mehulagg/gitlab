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
import IterationDropdown from './iteration_dropdown.vue';

export default {
  noIteration: iterationSelectTextMap.noIteration,
  iterationText: iterationSelectTextMap.iteration,
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlLink,
    GlIcon,
    IterationDropdown,
  },
  inject: ['canEdit'],
  data() {
    return {
      searchTerm: '',
      editing: false,
      currentIteration: undefined,
      iterations: iterationSelectTextMap.noIterationItem,
    };
  },
  mounted() {
    console.log(this.canEdit);
    document.addEventListener('click', this.handleOffClick);
  },
  beforeDestroy() {
    document.removeEventListener('click', this.handleOffClick);
  },
  methods: {
    toggleDropdown() {
      this.editing = !this.editing;

      this.$nextTick(() => {
        if (this.editing) {
          this.$refs.search.focusInput();
        }
      });
    },
    handleOffClick(event) {
      if (!this.editing) return;

      if (!this.$refs.newDropdown.$el.contains(event.target)) {
        this.toggleDropdown(event);
      }
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <div v-gl-tooltip class="sidebar-collapsed-icon">
      <gl-icon :size="16" :aria-label="$options.iterationText" name="iteration" />
      <span class="collapse-truncated-title">{{ 'iterationTitle' }}</span>
    </div>
    <div class="title hide-collapsed mt-3">
      {{ $options.iterationText }}
      <gl-button
        v-if="canEdit"
        variant="link"
        class="js-sidebar-dropdown-toggle edit-link gl-shadow-none float-right gl-reset-color! btn-link-hover"
        data-testid="iteration-edit-link"
        data-track-label="right_sidebar"
        data-track-property="iteration"
        data-track-event="click_edit_button"
        data-qa-selector="edit_iteration_link"
        @click.stop="toggleDropdown"
        >{{ __('Edit') }}</gl-button
      >
    </div>
    <!-- <div data-testid="select-iteration" class="hide-collapsed">
      <span v-if="showNoIterationContent" class="no-value">{{ $options.noIteration }}</span>
      <gl-link v-else-if="!editing" data-qa-selector="iteration_link" :href="iterationUrl"
        ><strong>{{ iterationTitle }}</strong></gl-link
      >
    </div> -->
    <!-- <gl-dropdown
      v-show="editing"
      ref="newDropdown"
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
    </gl-dropdown> -->
    <iteration-dropdown :editing="editing" />
  </div>
</template>
