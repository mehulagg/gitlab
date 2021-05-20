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
import {
  issuableEpicQueries,
  epicsQueries,
  iterationDisplayState,
  issuableIterationQueries,
  iterationsQueries,
} from '../constants';

export const IssuableAttributeType = {
  Iteration: 'iteration',
  Epic: 'epic',
  Milestone: 'milestone',
};

export const noAttributeId = null;

export default {
  noAttributeId,
  i18n: {
    [IssuableAttributeType.Iteration]: __('Iteration'),
    [IssuableAttributeType.Epic]: __('Epic'),
    [IssuableAttributeType.Milestone]: __('Milestone'),
    none: __('None'),
  },
  queries: {
    [IssuableAttributeType.Iteration]: {
      current: issuableIterationQueries,
      list: iterationsQueries,
    },
    [IssuableAttributeType.Epic]: {
      current: issuableEpicQueries,
      list: epicsQueries,
    },
  },
  tracking: {
    label: 'right_sidebar',
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
    issuableAttribute: {
      type: String,
      required: true,
      validator(value) {
        return [
          IssuableAttributeType.Iteration,
          IssuableAttributeType.Epic,
          IssuableAttributeType.Milestone,
        ].includes(value);
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
    currentAttribute: {
      query() {
        const {
          queries: {
            [this.issuableAttribute]: {
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
        return data?.workspace?.issuable.attribute;
      },
      error(error) {
        createFlash({ message: this.$options.i18n.currentFetchError });
        Sentry.captureException(error);
      },
    },
    attributesList: {
      query() {
        const {
          queries: {
            [this.issuableAttribute]: {
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
          return data?.workspace?.attributes.nodes;
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
      currentAttribute: null,
      attributesList: [],
      tracking: {
        ...this.$options.tracking,
        property: this.issuableAttribute,
      },
    };
  },
  computed: {
    attribute() {
      return this.attributesList.find(({ id }) => id === this.currentAttribute);
    },
    attributeTitle() {
      return this.currentAttribute?.title;
    },
    attributeUrl() {
      return this.currentAttribute?.webUrl;
    },
    dropdownText() {
      return this.currentAttribute
        ? this.currentAttribute?.title
        : this.$options.i18n[this.issuableAttribute];
    },
    loading() {
      return this.$apollo.queries.currentAttribute.loading;
    },
    emptyPropsList() {
      return this.attributesList.length === 0;
    },
    attributeTypeTitle() {
      return this.$options.i18n[this.issuableAttribute];
    },
    i18n() {
      return {
        noAttribute: sprintf(s__('DropdownWidget|No %{issuableAttribute}'), {
          issuableAttribute: this.issuableAttribute,
        }),
        assignAttribute: sprintf(s__('DropdownWidget|Assign %{issuableAttribute}'), {
          issuableAttribute: this.issuableAttribute,
        }),
        selectFail: sprintf(
          s__(
            'DropdownWidget|Failed to set %{issuableAttribute} on this %{issuableType}. Please try again.',
          ),
          { issuableAttribute: this.issuableAttribute, issuableType: this.issuableType },
        ),
        noAttributesFound: sprintf(s__('DropdownWidget|No %{issuableAttribute}s found'), {
          issuableAttribute: this.issuableAttribute,
        }),
        updateError: sprintf(
          s__(
            'DropdownWidget|An error occurred while assigning the selected %{issuableAttribute} to the %{issuableType}.',
          ),
          { issuableAttribute: this.issuableAttribute, issuableType: this.issuableType },
        ),
        listFetchError: sprintf(
          s__(
            'DropdownWidget|Failed to fetch the %{issuableAttribute} for this %{issuableType}. Please try again.',
          ),
          { issuableAttribute: this.issuableAttribute, issuableType: this.issuableType },
        ),
        currentFetchError: sprintf(
          s__(
            'DropdownWidget|An error occurred while fetching the assigned %{issuableAttribute} of the selected %{issuableType}.',
          ),
          { issuableAttribute: this.issuableAttribute, issuableType: this.issuableType },
        ),
      };
    },
  },
  methods: {
    updateAttribute(attributeId) {
      if (this.currentAttribute === null && attributeId === null) return;
      if (attributeId === this.currentAttribute?.id) return;

      this.updating = true;

      const selectedAttribute = this.attributesList.find((p) => p.id === attributeId);
      this.selectedTitle = selectedAttribute ? selectedAttribute.title : this.$options.i18n.none;

      const {
        [this.issuableAttribute]: {
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
            attributeId,
            iid: this.iid,
          },
        })
        .then(({ data }) => {
          // TAKE CARE OF THIS
          if (data.issuableSetAttribute?.errors?.length) {
            createFlash(data.issuableSetAttribute.errors[0]);
            Sentry.captureException(data.issuableSetAttribute.errors[0]);
          } else {
            this.$emit('attribute-updated', data);
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
    isAttributeChecked(attributeId = undefined) {
      return (
        attributeId === this.currentAttribute?.id || (!this.currentAttribute?.id && !attributeId)
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
      :title="attributeTypeTitle"
      data-testid="attribute-edit-link"
      :tracking="tracking"
      :loading="updating || loading"
      @open="handleOpen"
      @close="handleClose"
    >
      <template #collapsed>
        <div v-if="isClassicSidebar" v-gl-tooltip class="sidebar-collapsed-icon">
          <gl-icon :size="16" :aria-label="attributeTypeTitle" :name="issuableAttribute" />
          <span class="collapse-truncated-title">{{ attributeTitle }}</span>
        </div>
        <div
          data-testid="select-attribute"
          :class="isClassicSidebar ? 'hide-collapsed' : 'gl-mt-3'"
        >
          <strong v-if="updating">{{ selectedTitle }}</strong>
          <span v-else-if="!updating && !currentAttribute" class="gl-text-gray-500">
            {{ $options.i18n.none }}
          </span>
          <gl-link
            v-else
            data-qa-selector="iteration_link"
            class="gl-text-gray-900! gl-font-weight-bold"
            :href="attributeUrl"
          >
            <strong>{{ attributeTitle }}</strong>
          </gl-link>
        </div>
      </template>
      <template #default>
        <gl-dropdown
          ref="newDropdown"
          lazy
          :header-text="i18n.assignAttribute"
          :text="dropdownText"
          :loading="loading"
          class="gl-w-full"
          @shown="setFocus"
        >
          <gl-search-box-by-type ref="search" v-model="searchTerm" />
          <gl-dropdown-item
            data-testid="no-attribute-item"
            :is-check-item="true"
            :is-checked="isAttributeChecked($options.noAttributeId)"
            @click="updateAttribute($options.noAttributeId)"
          >
            {{ i18n.noAttribute }}
          </gl-dropdown-item>
          <gl-dropdown-divider />
          <gl-loading-icon
            v-if="$apollo.queries.attributesList.loading"
            class="gl-py-4"
            data-testid="loading-icon-dropdown"
          />
          <template v-else>
            <gl-dropdown-text v-if="emptyPropsList">
              {{ i18n.noAttributesFound }}
            </gl-dropdown-text>
            <gl-dropdown-item
              v-for="attrItem in attributesList"
              :key="attrItem.id"
              :is-check-item="true"
              :is-checked="isAttributeChecked(attrItem.id)"
              data-testid="attribute-items"
              @click="updateAttribute(attrItem.id)"
            >
              {{ attrItem.title }}
            </gl-dropdown-item>
          </template>
        </gl-dropdown>
      </template>
    </sidebar-editable-item>
  </div>
</template>
