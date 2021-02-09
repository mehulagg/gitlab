<script>
import {
  GlLink,
  GlDropdown,
  GlDropdownItem,
  GlDropdownText,
  GlSearchBoxByType,
  GlDropdownDivider,
  GlLoadingIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import { mapGetters } from 'vuex';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import createFlash from '~/flash';
import * as Sentry from '~/sentry/wrapper';
import { __ } from '~/locale';
import groupIterationsQuery from 'ee/sidebar/queries/group_iterations.query.graphql';
import currentIterationQuery from 'ee/sidebar/queries/issue_iteration.query.graphql';
import setIssueIterationMutation from 'ee/sidebar/queries/set_iteration_on_issue.mutation.graphql';
import { iterationSelectTextMap, iterationDisplayState, noIteration } from 'ee/sidebar/constants';

export default {
  noIteration,
  i18n: {
    iteration: iterationSelectTextMap.iteration,
    noIteration: iterationSelectTextMap.noIteration,
    assignIteration: iterationSelectTextMap.assignIteration,
    iterationSelectFail: iterationSelectTextMap.iterationSelectFail,
    noIterationsFound: iterationSelectTextMap.noIterationsFound,
    currentIterationFetchError: iterationSelectTextMap.currentIterationFetchError,
    iterationsFetchError: iterationSelectTextMap.iterationsFetchError,
    edit: __('Edit'),
    none: __('None'),
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    BoardEditableItem,
    GlLink,
    GlDropdown,
    GlDropdownItem,
    GlDropdownText,
    GlDropdownDivider,
    GlSearchBoxByType,
    GlLoadingIcon,
  },
  apollo: {
    currentIteration: {
      query: currentIterationQuery,
      variables() {
        return {
          fullPath: this.projectPathForActiveIssue,
          iid: this.activeIssue.iid,
        };
      },
      update(data) {
        return data?.project?.issue.iteration;
      },
      error(error) {
        createFlash({ message: this.$options.i18n.currentIterationFetchError });
        Sentry.captureException(error);
      },
    },
    iterations: {
      query: groupIterationsQuery,
      skip() {
        return !this.editing;
      },
      debounce: 250,
      variables() {
        const search = this.searchTerm === '' ? '' : `"${this.searchTerm}"`;

        return {
          fullPath: this.groupPathForActiveIssue,
          title: search,
          state: iterationDisplayState,
        };
      },
      update(data) {
        return data?.group?.iterations.nodes || [];
      },
      error(error) {
        createFlash({ message: this.$options.i18n.iterationsFetchError });
        Sentry.captureException(error);
      },
    },
  },
  data() {
    return {
      searchTerm: '',
      editing: false,
      updating: false,
      selectedTitle: null,
      currentIteration: null,
      iterations: [],
    };
  },
  computed: {
    ...mapGetters(['activeIssue', 'projectPathForActiveIssue', 'groupPathForActiveIssue']),
    showCurrentIteration() {
      return this.currentIteration !== null && !this.editing;
    },
    iteration() {
      return this.iterations.find(({ id }) => id === this.currentIteration);
    },
    iterationTitle() {
      return this.currentIteration?.title;
    },
    iterationUrl() {
      return this.currentIteration?.webUrl;
    },
    dropdownText() {
      return this.currentIteration ? this.currentIteration?.title : this.$options.i18n.iteration;
    },
    showNoIterationContent() {
      return !this.updating && !this.currentIteration;
    },
    loading() {
      return this.updating || this.$apollo.queries.currentIteration.loading;
    },
    noIterations() {
      return this.iterations.length === 0;
    },
  },
  methods: {
    handleOpen() {
      this.editing = true;
      this.showDropdown();
    },
    handleClose() {
      this.$refs.editableItem.collapse();
    },
    setIteration(iterationId) {
      this.editing = false;
      if (iterationId === this.currentIteration?.id) return;

      this.updating = true;

      const selectedIteration = this.iterations.find((i) => i.id === iterationId);
      this.selectedTitle = selectedIteration ? selectedIteration.title : this.$options.i18n.none;

      this.$apollo
        .mutate({
          mutation: setIssueIterationMutation,
          variables: {
            projectPath: this.projectPathForActiveIssue,
            iterationId,
            iid: this.activeIssue.iid,
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
          this.updating = false;
          this.searchTerm = '';
          this.selectedTitle = null;
          this.editing = false;
        });
    },
    isIterationChecked(iterationId = undefined) {
      return (
        iterationId === this.currentIteration?.id || (!this.currentIteration?.id && !iterationId)
      );
    },
    showDropdown() {
      this.$refs.newDropdown.show();
    },
  },
};
</script>

<template>
  <board-editable-item
    ref="editableItem"
    :title="$options.i18n.iteration"
    :loading="loading"
    @open="handleOpen"
    @close="handleClose"
  >
    <template #collapsed>
      <gl-link v-if="showCurrentIteration" :href="iterationUrl"
        ><strong class="gl-text-gray-900">{{ iterationTitle }}</strong></gl-link
      >
    </template>
    <gl-dropdown
      ref="newDropdown"
      lazy
      :header-text="$options.i18n.assignIteration"
      :text="dropdownText"
      :loading="loading"
      class="gl-w-full"
      @hide="handleClose"
    >
      <gl-search-box-by-type ref="search" v-model="searchTerm" />
      <gl-dropdown-item
        data-testid="no-iteration-item"
        :is-check-item="true"
        :is-checked="isIterationChecked($options.noIteration)"
        @click="setIteration($options.noIteration)"
      >
        {{ $options.i18n.noIteration }}
      </gl-dropdown-item>
      <gl-dropdown-divider />
      <gl-loading-icon
        v-if="$apollo.queries.iterations.loading"
        class="gl-py-4"
        data-testid="loading-icon-dropdown"
      />
      <template v-else>
        <gl-dropdown-text v-if="noIterations">
          {{ $options.i18n.noIterationsFound }}
        </gl-dropdown-text>
        <gl-dropdown-item
          v-for="iterationItem in iterations"
          :key="iterationItem.id"
          :is-check-item="true"
          :is-checked="isIterationChecked(iterationItem.id)"
          data-testid="iteration-items"
          @click="setIteration(iterationItem.id)"
          >{{ iterationItem.title }}</gl-dropdown-item
        >
      </template>
    </gl-dropdown>
  </board-editable-item>
</template>
