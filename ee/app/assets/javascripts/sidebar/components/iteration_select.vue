<script>
import {
  GlButton,
  GlLink,
  GlDropdown,
  GlDropdownItem,
  GlDropdownText,
  GlSearchBoxByType,
  GlDropdownDivider,
  GlLoadingIcon,
  GlIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import groupIterationsQuery from '../queries/group_iterations.query.graphql';
import currentIterationQuery from '../queries/issue_iteration.query.graphql';
import setIssueIterationMutation from '../queries/set_iteration_on_issue.mutation.graphql';
import { iterationSelectTextMap, iterationDisplayState } from '../constants';
import createFlash from '~/flash';
import { __ } from '~/locale';

export default {
  i18n: {
    iteration: iterationSelectTextMap.iteration,
    noIteration: iterationSelectTextMap.noIteration,
    assignIteration: iterationSelectTextMap.assignIteration,
    iterationSelectFail: iterationSelectTextMap.iterationSelectFail,
    noIterationsFound: iterationSelectTextMap.noIterationsFound,
    edit: __('Edit'),
    none: __('None'),
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlLink,
    GlDropdown,
    GlDropdownItem,
    GlDropdownText,
    GlDropdownDivider,
    GlSearchBoxByType,
    GlIcon,
    GlLoadingIcon,
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
        return data?.project?.issue?.iteration;
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
          fullPath: this.groupPath,
          title: search,
          state: iterationDisplayState,
        };
      },
      update(data) {
        const nodes = data.group?.iterations?.nodes || [];

        return nodes;
      },
    },
  },
  data() {
    return {
      searchTerm: '',
      editing: false,
      currentIteration: null,
      selectedIteration: null,
      iterations: [],
      updating: false,
    };
  },
  computed: {
    iteration() {
      return this.iterations.find(({ id }) => id === this.currentIteration);
    },
    iterationTitle() {
      if (this.updating && this.selectedIteration) {
        return this.selectedIteration.title;
      }

      return this.currentIteration ? this.currentIteration.title : this.$options.i18n.none;
    },
    iterationUrl() {
      return this.currentIteration?.webUrl;
    },
    dropdownText() {
      if (this.updating && this.selectedIteration) {
        return this.selectedIteration.title;
      }

      return this.currentIteration ? this.currentIteration.title : this.$options.i18n.iteration;
    },
    showNoIterationContent() {
      return !this.editing && !this.currentIteration;
    },
    loading() {
      return this.updating || this.$apollo.queries.currentIteration.loading;
    },
    noIterationsFound() {
      return this.iterations.length === 0 && this.searchTerm !== '';
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
          this.showDropdown();
          this.setFocus();
        }
      });
    },
    setIteration(iterationId) {
      if (iterationId === this.currentIteration?.id) return;

      this.editing = false;
      this.updating = true;
      this.selectedIteration = this.iterations.find((i) => i.id === iterationId) || null;

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
          this.updating = false;
          this.searchTerm = '';
          this.selectedIteration = null;
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
    showDropdown() {
      this.$refs.newDropdown.show();
    },
    setFocus() {
      this.$refs.search.focusInput();
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <div v-gl-tooltip class="sidebar-collapsed-icon">
      <gl-icon :size="16" :aria-label="$options.i18n.iteration" name="iteration" />
      <span class="collapse-truncated-title">{{ iterationTitle }}</span>
    </div>
    <div class="title hide-collapsed gl-mt-4">
      {{ $options.i18n.iteration }}
      <gl-loading-icon v-if="loading" class="gl-ml-2" :inline="true" />
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
        >{{ $options.i18n.edit }}</gl-button
      >
    </div>
    <div data-testid="select-iteration" class="hide-collapsed">
      <span v-if="showNoIterationContent" class="no-value">{{ $options.i18n.none }}</span>
      <gl-link v-else-if="!editing" data-qa-selector="iteration_link" :href="iterationUrl"
        ><strong>{{ iterationTitle }}</strong></gl-link
      >
    </div>
    <gl-dropdown
      v-show="editing"
      ref="newDropdown"
      :header-text="$options.i18n.assignIteration"
      :text="iterationTitle"
      :loading="loading"
      class="dropdown gl-w-full"
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
      <gl-loading-icon v-if="$apollo.queries.iterations.loading" class="gl-py-4" />
      <div v-else>
        <gl-dropdown-text v-if="noIterationsFound">
          {{ $options.i18n.noIterationsFound }}
        </gl-dropdown-text>
        <gl-dropdown-item
          v-for="iterationItem in iterations"
          :key="iterationItem.id"
          :is-check-item="true"
          :is-checked="isIterationChecked(iterationItem.id)"
          @click="setIteration(iterationItem.id)"
          >{{ iterationItem.title }}</gl-dropdown-item
        >
      </div>
    </gl-dropdown>
  </div>
</template>
