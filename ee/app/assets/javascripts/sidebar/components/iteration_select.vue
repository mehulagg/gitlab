<script>
import { GlDropdown, GlDropdownItem, GlSearchBoxByType, GlDropdownDivider } from '@gitlab/ui';
import groupIterationsQuery from '../queries/group_iterations.query.graphql';
import currentIterationQuery from '../queries/issue_iteration.query.graphql';
import setIssueIterationMutation from '../queries/set_iteration_on_issue.mutation.graphql';
import { iterationSelectTextMap, iterationDisplayState } from '../constants';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { __ } from '~/locale';

export default {
  i18n: {
    assignIteration: __('Assign Iteration'),
    noIteration: iterationSelectTextMap.noIteration,
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlDropdownDivider,
  },
  props: {
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
    dropdownOpen: {
      required: true,
      type: Boolean,
      default: false,
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
        const hasIteration = data?.project?.issue?.iteration?.id;
        const currentIteration = data?.project?.issue?.iteration;

        return hasIteration ? currentIteration : null;
      },
      result({ data }) {
        const hasIteration = data?.project?.issue?.iteration?.id;
        const currentIteration = data?.project?.issue?.iteration;

        this.$emit('iterationUpdate', hasIteration ? currentIteration : null);
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

        return nodes;
      },
    },
  },
  data() {
    return {
      searchTerm: '',
      currentIteration: undefined,
      iterations: [],
    };
  },
  computed: {
    dropdownText() {
      return this.currentIteration ? this.currentIteration.title : this.$options.i18n.noIteration;
    },
  },
  watch: {
    dropdownOpen: {
      handler() {
        this.$nextTick(() => {
          this.showDropdown();
        });
      },
    },
  },
  methods: {
    setIteration(iterationId) {
      if (iterationId === this.currentIteration?.id) return;

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
        })
        .finally(() => {
          this.searchTerm = '';
          this.$emit('dropdownClose');
        });
    },
    isIterationChecked(iterationId = undefined) {
      return (
        iterationId === this.currentIteration?.id || (!this.currentIteration?.id && !iterationId)
      );
    },
    showDropdown() {
      if (this.dropdownOpen) {
        this.$refs.dropdown.show();
      }
    },
    setFocus() {
      this.$refs.search.focusInput();
    },
  },
};
</script>

<template>
  <gl-dropdown
    v-if="dropdownOpen"
    ref="dropdown"
    :text="dropdownText"
    :header-text="$options.i18n.assignIteration"
    block
    @shown="setFocus"
  >
    <gl-search-box-by-type ref="search" v-model="searchTerm" />
    <gl-dropdown-item
      data-testid="no-iteration-item"
      :is-check-item="true"
      :is-checked="isIterationChecked(null)"
      @click="setIteration(null)"
    >
      {{ $options.i18n.noIteration }}
    </gl-dropdown-item>
    <gl-dropdown-divider />
    <gl-dropdown-item
      v-for="iterationItem in iterations"
      :key="iterationItem.id"
      :is-check-item="true"
      :is-checked="isIterationChecked(iterationItem.id)"
      @click="setIteration(iterationItem.id)"
      >{{ iterationItem.title }}</gl-dropdown-item
    >
  </gl-dropdown>
</template>
