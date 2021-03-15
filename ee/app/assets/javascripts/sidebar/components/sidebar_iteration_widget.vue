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
import { __, s__, sprintf } from '~/locale';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import { iterationDisplayState, issuableIterationQueries, iterationsQueries } from '../constants';

export const PropType = {
  Iteration: 'iteration',
  Epic: 'epic',
  Milestone: 'milestone',
};

export const noPropId = null;

export default {
  noPropId,
  i18n: {
    [PropType.Iteration]: __('Iteration'),
    [PropType.Epic]: __('Epic'),
    [PropType.Milestone]: __('Milestone'),
    none: __('None'),
  },
  queries: {
    [PropType.Iteration]: {
      current: issuableIterationQueries,
      list: iterationsQueries,
    },
  },
  tracking: {
    label: 'right_sidebar',
    event: 'click_edit_button',
  },
  trackingProp: {
    [PropType.Iteration]: {
      property: 'iteration',
    },
    [PropType.Epic]: {
      property: 'epic',
    },
    [PropType.Milestone]: {
      property: 'milestone',
    },
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
    propType: {
      type: String,
      required: true,
      validator(value) {
        return [PropType.Iteration, PropType.Epic, PropType.Milestone].includes(value);
      },
    },
    workspacePath: {
      required: true,
      type: String,
    },
    iid: {
      required: true,
      type: String,
    },
    propsWorkspacePath: {
      required: true,
      type: String,
    },
    issuableType: {
      type: String,
      required: true,
      validator(value) {
        // Add supported IssuableType here along with graphql queries
        // as this widget can be used for addtional issuable types.
        return [IssuableType.Issue].includes(value);
      },
    },
  },
  apollo: {
    currentProp: {
      query() {
        const {
          queries: {
            [this.propType]: {
              current: {
                [this.issuableType]: { query },
              },
            },
          },
        } = this.$options;

        return query;
      },
      variables() {
        return {
          fullPath: this.workspacePath,
          iid: this.iid,
        };
      },
      update(data) {
        return data?.workspace?.issuable.prop;
      },
      error(error) {
        createFlash({ message: this.$options.i18n.currentFetchError });
        Sentry.captureException(error);
      },
    },
    propsList: {
      query() {
        const {
          queries: {
            [this.propType]: {
              list: {
                [this.issuableType]: { query },
              },
            },
          },
        } = this.$options;

        return query;
      },
      skip() {
        return !this.editing;
      },
      debounce: 250,
      variables() {
        return {
          fullPath: this.propsWorkspacePath,
          title: this.searchTerm,
          // TODO
          state: iterationDisplayState,
        };
      },
      update(data) {
        if (data?.workspace) {
          return data?.workspace?.props.nodes;
        }
        return [];
      },
      error(error) {
        createFlash({ message: this.$options.i18n.listFetchError });
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
      currentProp: null,
      propsList: [],
    };
  },
  computed: {
    prop() {
      return this.propsList.find(({ id }) => id === this.currentProp);
    },
    propTitle() {
      return this.currentProp?.title;
    },
    propUrl() {
      return this.currentProp?.webUrl;
    },
    dropdownText() {
      return this.currentProp ? this.currentProp?.title : this.$options.i18n[this.propType];
    },
    loading() {
      return this.$apollo.queries.currentProp.loading;
    },
    emptyPropsList() {
      return this.propsList.length === 0;
    },
    propTypeTitle() {
      return this.$options.i18n[this.propType];
    },
    i18n() {
      return {
        noProp: sprintf(s__('DropdownWidget|No %{propType}'), {
          propType: this.propType,
        }),
        assignProp: sprintf(s__('DropdownWidget|Assign %{propType}'), {
          propType: this.propType,
        }),
        selectFail: sprintf(
          s__(
            'DropdownWidget|Failed to set %{propType} on this %{issuableType}. Please try again.',
          ),
          { propType: this.propType, issuableType: this.issuableType },
        ),
        noPropsFound: sprintf(s__('DropdownWidget|No %{propType}s found'), {
          propType: this.propType,
        }),
        updateError: sprintf(
          s__(
            'DropdownWidget|An error occurred while assigning the selected %{propType} to the ${issuableType}.',
          ),
          { propType: this.propType, issuableType: this.issuableType },
        ),
        listFetchError: sprintf(
          s__(
            'DropdownWidget|Failed to fetch the %{propType} for this %{issuableType}. Please try again.',
          ),
          { propType: this.propType, issuableType: this.issuableType },
        ),
        currentFetchError: sprintf(
          s__(
            'DropdownWidget|An error occurred while fetching the assigned %{propType} of the selected ${issuableType}.',
            { propType: this.propType, issuableType: this.issuableType },
          ),
        ),
      };
    },
  },
  methods: {
    updateProp(propId) {
      if (this.currentProp === null && propId === null) return;
      if (propId === this.currentProp?.id) return;

      this.updating = true;

      const selectedProp = this.propsList.find((p) => p.id === propId);
      this.selectedTitle = selectedProp ? selectedProp.title : this.$options.i18n.none;

      const {
        [this.propType]: {
          current: {
            [this.issuableType]: { mutation },
          },
        },
      } = this.$options.queries;

      this.$apollo
        .mutate({
          mutation,
          variables: {
            fullPath: this.workspacePath,
            propId,
            iid: this.iid,
          },
        })
        .then(({ data }) => {
          // TAKE CARE OF THIS
          if (data.issuableSetProp?.errors?.length) {
            createFlash(data.issuableSetProp.errors[0]);
            Sentry.captureException(data.issuableSetProp.errors[0]);
          } else {
            this.$emit('prop-updated', data);
          }
        })
        .catch((error) => {
          createFlash(this.$options.i18n.selectFail);
          Sentry.captureException(error);
        })
        .finally(() => {
          this.updating = false;
          this.searchTerm = '';
          this.selectedTitle = null;
        });
    },
    isPropChecked(propId = undefined) {
      return propId === this.currentProp?.id || (!this.currentProp?.id && !propId);
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
      :title="propTypeTitle"
      data-testid="prop-edit-link"
      :tracking="$options.tracking"
      :trakcing-prop="$options.trackingProp[propType]"
      :loading="updating || loading"
      @open="handleOpen"
      @close="handleClose"
    >
      <template #collapsed>
        <div v-if="isClassicSidebar" v-gl-tooltip class="sidebar-collapsed-icon">
          <gl-icon :size="16" :aria-label="propTypeTitle" :name="propType" />
          <span class="collapse-truncated-title">{{ propTitle }}</span>
        </div>
        <div data-testid="select-prop" :class="isClassicSidebar ? 'hide-collapsed' : 'gl-mt-3'">
          <strong v-if="updating">{{ selectedTitle }}</strong>
          <span v-else-if="!updating && !currentProp" class="gl-text-gray-500">{{
            $options.i18n.none
          }}</span>
          <gl-link
            v-else
            data-qa-selector="iteration_link"
            class="gl-text-gray-900! gl-font-weight-bold"
            :href="propUrl"
            ><strong>{{ propTitle }}</strong></gl-link
          >
        </div>
      </template>
      <template #default>
        <gl-dropdown
          ref="newDropdown"
          lazy
          :header-text="i18n.assignProp"
          :text="dropdownText"
          :loading="loading"
          class="gl-w-full"
          @shown="setFocus"
        >
          <gl-search-box-by-type ref="search" v-model="searchTerm" />
          <gl-dropdown-item
            data-testid="no-prop-item"
            :is-check-item="true"
            :is-checked="isPropChecked($options.noPropId)"
            @click="updateProp($options.noPropId)"
          >
            {{ i18n.noProp }}
          </gl-dropdown-item>
          <gl-dropdown-divider />
          <gl-loading-icon
            v-if="$apollo.queries.propsList.loading"
            class="gl-py-4"
            data-testid="loading-icon-dropdown"
          />
          <template v-else>
            <gl-dropdown-text v-if="emptyPropsList">
              {{ i18n.noPropsFound }}
            </gl-dropdown-text>
            <gl-dropdown-item
              v-for="propItem in propsList"
              :key="propItem.id"
              :is-check-item="true"
              :is-checked="isPropChecked(propItem.id)"
              data-testid="prop-items"
              @click="updateProp(propItem.id)"
              >{{ propItem.title }}</gl-dropdown-item
            >
          </template>
        </gl-dropdown>
      </template>
    </sidebar-editable-item>
  </div>
</template>
