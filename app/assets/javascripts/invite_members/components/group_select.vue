<script>
import { debounce } from 'lodash';
import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownText,
  GlSearchBoxByType,
  GlLoadingIcon,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import Api from '~/api';
import { GROUP_SEARCH_DELAY } from '../constants';

export default {
  name: 'GroupSelect',
  components: {
    GlLoadingIcon,
    GlDropdown,
    GlDropdownItem,
    GlDropdownText,
    GlSearchBoxByType,
  },
  model: {
    prop: 'selectedGroup',
    event: 'input',
  },
  data() {
    return {
      initialLoading: true,
      isFetching: false,
      groups: [],
      selectedGroup: {},
      searchTerm: '',
    };
  },
  computed: {
    selectedGroupName() {
      return this.selectedGroup.name || this.$options.i18n.dropdownText;
    },
    isFetchResultEmpty() {
      return this.groups.length === 0;
    },
  },
  watch: {
    searchTerm() {
      this.retrieveGroups();
    },
  },
  mounted() {
    this.retrieveGroups();

    this.initialLoading = false;
  },
  methods: {
    retrieveGroups: debounce(function debouncedRetrieveGroups() {
      return Api.groups(this.searchTerm, this.$options.defaultFetchOptions)
        .then((response) => {
          this.groups = response.map((group) => ({
            id: group.id,
            name: group.full_name,
            namespacedName: group.full_path,
            path: group.path,
          }));
          this.isFetching = false;
        })
        .catch(() => {
          this.isFetching = false;
        });
    }, GROUP_SEARCH_DELAY),
    selectGroup(groupId) {
      this.selectedGroup = this.groups.find((group) => group.id === groupId);

      this.$emit('setSelectedGroup', this.selectedGroup);
      this.$emit('input', this.selectedGroup);
    },
  },
  i18n: {
    dropdownText: s__(`GroupSelect|Select a group`),
    searchPlaceholder: s__(`GroupSelect|Search groups`),
    emptySearchResult: s__(`GroupSelect|No matching results`),
  },
  defaultFetchOptions: {
    exclude_internal: true,
    active: true,
  },
};
</script>
<template>
  <div>
    <gl-dropdown
      data-testid="group_select_dropdown"
      :text="selectedGroupName"
      block
      menu-class="gl-w-full!"
      :loading="initialLoading"
    >
      <gl-search-box-by-type
        v-model.trim="searchTerm"
        :placeholder="$options.i18n.searchPlaceholder"
      />
      <gl-dropdown-item
        v-for="group in groups"
        v-show="!isFetching"
        :key="group.id"
        :name="group.name"
        @click="selectGroup(group.id)"
      >
        {{ group.namespacedName }}
      </gl-dropdown-item>
      <gl-dropdown-text v-show="isFetching" data-testid="dropdown-text-loading-icon">
        <gl-loading-icon class="gl-mx-auto" />
      </gl-dropdown-text>
      <gl-dropdown-text v-if="isFetchResultEmpty && !isFetching" data-testid="empty-result-message">
        <span class="gl-text-gray-500">{{ $options.i18n.emptySearchResult }}</span>
      </gl-dropdown-text>
    </gl-dropdown>
  </div>
</template>
