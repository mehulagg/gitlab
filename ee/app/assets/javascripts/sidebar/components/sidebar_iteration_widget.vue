<script>
import {
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
import createFlash from '~/flash';
import { IssuableType } from '~/issue_show/constants';
import { __ } from '~/locale';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import {
  iterationSelectTextMap,
  iterationDisplayState,
  noIteration,
  issuableIterationQueries,
  iterationsQueries,
} from '../constants';

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
  issuableIterationQueries,
  iterationsQueries,
  tracking: {
    label: 'right_sidebar',
    property: 'iteration',
    event: 'click_edit_button',
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    SidebarEditableItem,
    GlLink,
    GlDropdown,
    GlDropdownItem,
    GlDropdownText,
    GlDropdownDivider,
    GlSearchBoxByType,
    GlIcon,
    GlLoadingIcon,
  },
  inject: {
    isClassicSidebar: {
      default: false,
    },
  },
  props: {
    workspacePath: {
      required: true,
      type: String,
    },
    iid: {
      required: true,
      type: String,
    },
    iterationsWorkspacePath: {
      required: true,
      type: String,
    },
    issuableType: {
      type: String,
      required: true,
      validator(value) {
        // Add supported IssuableType here along with graphql queries
        // as this widget is used for addtional issuable types.
        return [IssuableType.Issue].includes(value);
      },
    },
  },
  apollo: {
    currentIteration: {
      query() {
        return issuableIterationQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.workspacePath,
          iid: this.iid,
        };
      },
      update(data) {
        return data?.workspace?.issuable.iteration;
      },
      error(error) {
        createFlash({ message: this.$options.i18n.currentIterationFetchError });
        Sentry.captureException(error);
      },
    },
    iterations: {
      query() {
        return iterationsQueries[this.issuableType].query;
      },
      skip() {
        return !this.editing;
      },
      debounce: 250,
      variables() {
        return {
          fullPath: this.iterationsWorkspacePath,
          title: this.searchTerm,
          state: iterationDisplayState,
        };
      },
      update(data) {
        return data?.workspace?.iterations.nodes || [];
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
    loading() {
      return this.$apollo.queries.currentIteration.loading;
    },
    noIterations() {
      return this.iterations.length === 0;
    },
  },
  methods: {
    updateIteration(iterationId) {
      if (this.currentIteration === null && iterationId === null) return;
      if (iterationId === this.currentIteration?.id) return;

      this.updating = true;

      const selectedIteration = this.iterations.find((i) => i.id === iterationId);
      this.selectedTitle = selectedIteration ? selectedIteration.title : this.$options.i18n.none;

      this.$apollo
        .mutate({
          mutation: issuableIterationQueries[this.issuableType].mutation,
          variables: {
            fullPath: this.workspacePath,
            iterationId,
            iid: this.iid,
          },
        })
        .then(({ data }) => {
          if (data.issuableSetIteration?.errors?.length) {
            createFlash(data.issuableSetIteration.errors[0]);
            Sentry.captureException(data.issuableSetIteration.errors[0]);
          } else {
            this.$emit('iteration-updated', data);
          }
        })
        .catch((error) => {
          createFlash(this.$options.i18n.iterationSelectFail);
          Sentry.captureException(error);
        })
        .finally(() => {
          this.updating = false;
          this.searchTerm = '';
          this.selectedTitle = null;
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
    handleOpen() {
      this.editing = true;
      this.showDropdown();
    },
    handleClose() {
      this.editing = false;
    },
    setFocus() {
      this.$refs.search.focusInput();
    },
  },
};
</script>

<template>
  <div data-qa-selector="iteration_container">
    <sidebar-editable-item
      ref="editable"
      :title="$options.i18n.iteration"
      data-testid="iteration-edit-link"
      :tracking="$options.tracking"
      :loading="updating || loading"
      @open="handleOpen"
      @close="handleClose"
    >
      <template #collapsed>
        <div v-if="isClassicSidebar" v-gl-tooltip class="sidebar-collapsed-icon">
          <gl-icon :size="16" :aria-label="$options.i18n.iteration" name="iteration" />
          <span class="collapse-truncated-title">{{ iterationTitle }}</span>
        </div>
        <div
          data-testid="select-iteration"
          :class="isClassicSidebar ? 'hide-collapsed' : 'gl-mt-3'"
        >
          <strong v-if="updating">{{ selectedTitle }}</strong>
          <span v-else-if="!updating && !currentIteration" class="gl-text-gray-500">{{
            $options.i18n.none
          }}</span>
          <gl-link
            v-else
            data-qa-selector="iteration_link"
            class="gl-text-gray-900! gl-font-weight-bold"
            :href="iterationUrl"
            ><strong>{{ iterationTitle }}</strong></gl-link
          >
        </div>
      </template>
      <template #default>
        <gl-dropdown
          ref="newDropdown"
          lazy
          :header-text="$options.i18n.assignIteration"
          :text="dropdownText"
          :loading="loading"
          class="gl-w-full"
          @shown="setFocus"
        >
          <gl-search-box-by-type ref="search" v-model="searchTerm" />
          <gl-dropdown-item
            data-testid="no-iteration-item"
            :is-check-item="true"
            :is-checked="isIterationChecked($options.noIteration)"
            @click="updateIteration($options.noIteration)"
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
              @click="updateIteration(iterationItem.id)"
              >{{ iterationItem.title }}</gl-dropdown-item
            >
          </template>
        </gl-dropdown>
      </template>
    </sidebar-editable-item>
  </div>
</template>
