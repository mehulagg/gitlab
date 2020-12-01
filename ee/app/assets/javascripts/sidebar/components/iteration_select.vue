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
  noIteration: iterationSelectTextMap.noIteration,
  iterationText: iterationSelectTextMap.iteration,
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlLink,
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlDropdownSectionHeader,
    GlIcon,
  },
  props: {
    canEdit: {
      required: true,
      type: Boolean,
    },
    groupPath: {
      required: true,
      type: String,
    },
    projectPath: {
      required: true,
      type: String,
    },
    issueIid: {
      required: true,
      type: String,
    },
  },
  apollo: {
    currentIteration: {
      query: currentIterationQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          iid: this.issueIid,
        };
      },
      update(data) {
        return data?.project?.issue?.iteration?.id;
      },
    },
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
      editing: false,
      currentIteration: undefined,
      iterations: iterationSelectTextMap.noIterationItem,
    };
  },
  computed: {
    iteration() {
      return this.iterations.find(({ id }) => id === this.currentIteration);
    },
    iterationTitle() {
      return this.iteration?.title;
    },
    iterationUrl() {
      return this.iteration?.webUrl;
    },
    showNoIterationContent() {
      return !this.editing && !this.currentIteration;
    },
  },
  mounted() {
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
    setIteration(iterationId) {
      if (iterationId === this.currentIteration) return;

      this.editing = false;

      this.$apollo
        .mutate({
          mutation: setIssueIterationMutation,
          variables: {
            projectPath: this.projectPath,
            iterationId,
            iid: this.issueIid,
          },
        })
        .then(({ data }) => {
          if (data.issueSetIteration?.errors?.length) {
            createFlash(data.issueSetIteration.errors[0]);
          } else {
            this.currentIteration = data.issueSetIteration?.issue?.iteration?.id;
          }
        })
        .catch(() => {
          const { iterationSelectFail } = iterationSelectTextMap;

          createFlash(iterationSelectFail);
        });
    },
    handleOffClick(event) {
      if (!this.editing) return;

      if (!this.$refs.newDropdown.$el.contains(event.target)) {
        this.toggleDropdown(event);
      }
    },
    isIterationChecked(iterationId = undefined) {
      return iterationId === this.currentIteration || (!this.currentIteration && !iterationId);
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <div v-gl-tooltip class="sidebar-collapsed-icon">
      <gl-icon :size="16" :aria-label="$options.iterationText" name="iteration" />
      <span class="collapse-truncated-title">{{ iterationTitle }}</span>
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
    <div data-testid="select-iteration" class="hide-collapsed">
      <span v-if="showNoIterationContent" class="no-value">{{ $options.noIteration }}</span>
      <gl-link v-else-if="!editing" data-qa-selector="iteration_link" :href="iterationUrl"
        ><strong>{{ iterationTitle }}</strong></gl-link
      >
    </div>
    <gl-dropdown
      v-show="editing"
      ref="newDropdown"
      data-toggle="dropdown"
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
