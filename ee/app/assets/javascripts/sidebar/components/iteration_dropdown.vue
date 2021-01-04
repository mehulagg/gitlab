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
    editing: {
      required: false,
      default: true,
    },
  },
  inject: ['canEdit', 'groupPath', 'projectPath', 'issueIid'],
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
        return data?.project?.issue?.iteration;
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
      currentIteration: undefined,
      iterations: iterationSelectTextMap.noIterationItem,
    };
  },
  computed: {
    iteration() {
      return this.iterations.find(({ id }) => id === this.currentIteration);
    },
    iterationTitle() {
      return this.currentIteration?.title;
    },
    iterationUrl() {
      return this.currentIteration?.webUrl;
    },
    showNoIterationContent() {
      return !this.editing && !this.currentIteration?.id;
    },
  },
  methods: {
    setIteration(iterationId) {
      if (iterationId === this.currentIteration?.id) return;

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
      return (
        iterationId === this.currentIteration?.id || (!this.currentIteration?.id && !iterationId)
      );
    },
  },
};
</script>

<template>
  <div>
    <gl-dropdown
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
    </gl-dropdown>
  </div>
</template>
