<script>
import { GlDropdown, GlDropdownItem, GlSearchBoxByType, GlDropdownSectionHeader } from '@gitlab/ui';
import groupIterationsQuery from '../queries/group_iterations.query.graphql';
import currentIterationQuery from '../queries/issue_iteration.query.graphql';
import setIssueIterationMutation from '../queries/set_iteration_on_issue.mutation.graphql';
import { iterationSelectTextMap, iterationDisplayState } from '../constants';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { __ } from '~/locale';

export default {
  i18n: {
    noIteration: iterationSelectTextMap.noIteration,
    assignIteration: __('Assign Iteration'),
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlDropdownSectionHeader,
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
        const currentIteration = data?.project?.issue?.iteration;

        this.$emit('iterationUpdate', currentIteration);
        return currentIteration;
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
  watch: {
    dropdownOpen: {
      handler() {
        this.$nextTick(() => {
          if (this.dropdownOpen) {
            this.$refs.iterationSearch.focusInput();
          }
        });
      },
    },
  },
  computed: {
    dropdownText() {
      return this.currentIteration ? 'some iteration' : this.$options.i18n.noIteration;
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
          this.$emit('dropdownClose');
        });
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
  <gl-dropdown
    v-if="dropdownOpen"
    :text="dropdownText"
    class="gl-w-full"
    menu-class="gl-w-full!"
    :class="{ show: dropdownOpen }"
  >
    <gl-dropdown-section-header class="gl-display-flex gl-justify-content-center">{{
      $options.i18n.assignIteration
    }}</gl-dropdown-section-header>
    <gl-search-box-by-type ref="iterationSearch" v-model="searchTerm" />
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
