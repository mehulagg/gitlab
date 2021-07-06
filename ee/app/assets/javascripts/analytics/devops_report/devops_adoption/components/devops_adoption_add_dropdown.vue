<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlLoadingIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { TYPE_GROUP } from '~/graphql_shared/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import {
  DEBOUNCE_DELAY,
  DEVOPS_ADOPTION_GROUP_DROPDOWN_TEXT,
  DEVOPS_ADOPTION_GROUP_DROPDOWN_HEADER,
  DEVOPS_ADOPTION_ADMIN_DROPDOWN_TEXT,
  DEVOPS_ADOPTION_ADMIN_DROPDOWN_HEADER,
  DEVOPS_ADOPTION_NO_RESULTS,
  DEVOPS_ADOPTION_NO_SUB_GROUPS,
} from '../constants';
import bulkEnableDevopsAdoptionNamespacesMutation from '../graphql/mutations/bulk_enable_devops_adoption_namespaces.mutation.graphql';

export default {
  name: 'DevopsAdoptionAddDropdown',
  i18n: {
    noResults: DEVOPS_ADOPTION_NO_RESULTS,
  },
  debounceDelay: DEBOUNCE_DELAY,
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlLoadingIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: {
    isGroup: {
      default: false,
    },
    groupGid: {
      default: null,
    },
  },
  props: {
    groups: {
      type: Array,
      required: true,
    },
    searchTerm: {
      type: String,
      required: false,
      default: '',
    },
    isLoadingGroups: {
      type: Boolean,
      required: false,
      default: false,
    },
    hasSubgroups: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    filteredGroupsLength() {
      return this.groups?.length;
    },
    dropdownTitle() {
      return this.isGroup
        ? DEVOPS_ADOPTION_GROUP_DROPDOWN_TEXT
        : DEVOPS_ADOPTION_ADMIN_DROPDOWN_TEXT;
    },
    dropdownHeader() {
      return this.isGroup
        ? DEVOPS_ADOPTION_GROUP_DROPDOWN_HEADER
        : DEVOPS_ADOPTION_ADMIN_DROPDOWN_HEADER;
    },
    tooltipText() {
      return this.isLoadingGroups || this.hasSubgroups ? false : DEVOPS_ADOPTION_NO_SUB_GROUPS;
    },
  },
  beforeDestroy() {
    clearTimeout(this.timeout);
    this.timeout = null;
  },
  methods: {
    enableGroup(id) {
      this.$apollo
        .mutate({
          mutation: bulkEnableDevopsAdoptionNamespacesMutation,
          variables: {
            namespaceIds: [convertToGraphQLId(TYPE_GROUP, id)],
            displayNamespaceId: this.groupGid,
          },
          update: (store, { data }) => {
            const {
              bulkEnableDevopsAdoptionNamespaces: { enabledNamespaces, errors: requestErrors },
            } = data;

            if (!requestErrors.length) this.$emit('enabledNamespacesAdded', enabledNamespaces);
          },
        })
        .catch((error) => {
          Sentry.captureException(error);
        });
    },
  },
};
</script>
<template>
  <gl-dropdown
    v-gl-tooltip="tooltipText"
    :text="dropdownTitle"
    :header-text="dropdownHeader"
    :disabled="!hasSubgroups"
    @show="$emit('trackModalOpenState', true)"
    @hide="$emit('trackModalOpenState', false)"
  >
    <template #header>
      <gl-search-box-by-type
        :debounce="$options.debounceDelay"
        @input="$emit('fetchGroups', $event)"
      />
    </template>
    <gl-loading-icon v-if="isLoadingGroups" />
    <template v-else>
      <gl-dropdown-item
        v-for="group in groups"
        :key="group.id"
        data-testid="group-row"
        @click="enableGroup(group.id)"
      >
        {{ group.full_name }}
      </gl-dropdown-item>
      <gl-dropdown-item v-show="!filteredGroupsLength" data-testid="no-results">{{
        $options.i18n.noResults
      }}</gl-dropdown-item>
    </template>
  </gl-dropdown>
</template>
