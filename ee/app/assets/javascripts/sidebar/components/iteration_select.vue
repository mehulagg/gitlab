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
import * as Sentry from '@sentry/browser';
import Vue from 'vue';
import createFlash from '~/flash';
import { __ } from '~/locale';
import { IssuableType } from '~/issue_show/constants';
import {
  iterationSelectTextMap,
  iterationDisplayState,
  noIteration,
  currentIterationQueries,
  iterationsQueries,
} from '../constants';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';

export const iterationsWidget = Vue.observable({
  updateIterations: null,
});

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
  iterationsQueries,
  currentIterationQueries,
  trackAttributes: {
    label: "right_sidebar",
    property: "iteration",
    event: "click_edit_button",
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    SidebarEditableItem,
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
    issuableType: {
      type: String,
      required: false,
      default: IssuableType.Issue,
      validator(value) {
        return [IssuableType.Issue].includes(value);
      },
    },
  },
  apollo: {
    currentIteration: {
      query() {
        return this.$options.currentIterationQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.projectPath,
          iid: this.issueIid,
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
      query() {
        return this.$options.iterationsQueries[this.issuableType].query;
      },
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
    isSettingIterations() {
      return false;
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

      if (this.editing) {
        this.showDropdown();
      }
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
          this.selectedTitle = null;
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
    saveIterations() {
      // TODO
      return null;
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <sidebar-editable-item
      ref="toggle"
      :loading="isSettingIterations"
      :title="$options.i18n.iteration"
      @open="setFocus"
      @close="saveIterations"
      data-testid="iteration-edit-link"
      :trackAttrs="$options.trackAttributes"
    >
      <template #collapsed>
        <div v-gl-tooltip class="sidebar-collapsed-icon">
          <gl-icon :size="16" :aria-label="$options.i18n.iteration" name="iteration" />
          <span class="collapse-truncated-title">{{ iterationTitle }}</span>
        </div>
        <div data-testid="select-iteration" class="hide-collapsed">
          <strong v-if="updating">{{ selectedTitle }}</strong>
          <span v-else-if="showNoIterationContent" class="gl-text-gray-500">{{
            $options.i18n.none
          }}</span>
          <gl-link v-else data-qa-selector="iteration_link" :href="iterationUrl"
            ><strong>{{ iterationTitle }}</strong></gl-link
          >
        </div>
      </template>
      <template #default>
        <gl-dropdown
          v-show="editing"
          ref="newDropdown"
          lazy
          :header-text="$options.i18n.assignIteration"
          :text="dropdownText"
          :loading="loading"
          class="gl-w-full"
          @shown="setFocus"
          @hidden="toggleDropdown"
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
      </template>
    </sidebar-editable-item>
  </div>
</template>
