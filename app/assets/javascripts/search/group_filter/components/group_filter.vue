<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlSearchBoxByType,
  GlButton,
  GlLoadingIcon,
  GlIcon,
  GlSkeletonLoader,
  GlTooltipDirective,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { __ } from '~/locale';
import { visitUrl, setUrlParams } from '~/lib/utils/url_utility';
import { ANY, GROUP_QUERY_PARAM } from '../constants';

export default {
  name: 'GroupFilter',
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlSearchBoxByType,
    GlButton,
    GlLoadingIcon,
    GlIcon,
    GlSkeletonLoader,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  data() {
    return {
      groupSearch: '',
    };
  },
  computed: {
    ...mapState(['initialGroup', 'fetchingInitialGroup', 'groups', 'fetchingGroups', 'query']),
    selectedGroup: {
      get() {
        return this.initialGroup ? this.initialGroup.id : ANY.id;
      },
      set(groupId) {
        visitUrl(setUrlParams({ [GROUP_QUERY_PARAM]: groupId }));
      },
    },
    selectedGroupText() {
      if (this.fetchingInitialGroup) {
        return __('Loading...');
      }

      if (this.selectedGroup === ANY.id) {
        return ANY.name;
      }

      return this.initialGroup.name;
    },
  },
  created() {
    if (this.query[GROUP_QUERY_PARAM]) {
      this.fetchInitialGroup(this.query[GROUP_QUERY_PARAM]);
    }
  },
  methods: {
    ...mapActions(['fetchGroups', 'fetchInitialGroup']),
    isGroupSelected(groupId) {
      return groupId === this.selectedGroup;
    },
    handleGroupChange(groupId) {
      this.selectedGroup = groupId;
    },
    hideDropdown() {
      this.$refs.groupFilter.hide(true);
    },
  },
  ANY,
};
</script>

<template>
  <gl-dropdown
    ref="groupFilter"
    class="gl-w-full"
    menu-class="gl-w-full!"
    toggle-class="gl-text-truncate"
    @show="fetchGroups(groupSearch)"
  >
    <template #button-content>
      <span class="dropdown-toggle-text gl-flex-grow-1 gl-text-truncate">
        {{ selectedGroupText }}
      </span>
      <gl-loading-icon v-if="fetchingGroups || fetchingInitialGroup" inline class="mr-2" />
      <gl-icon
        v-if="selectedGroup !== $options.ANY.id"
        v-gl-tooltip
        name="clear"
        :title="__('Clear')"
        class="gl-text-gray-200! gl-hover-text-blue-800!"
        @click.stop="handleGroupChange($options.ANY.id)"
      />
      <gl-icon name="chevron-down" />
    </template>
    <div
      class="gl-display-flex gl-align-items-center gl-justify-content-center gl-relative gl-mb-3"
    >
      <header class="gl-font-weight-bold">{{ __('Filter results by group') }}</header>
      <gl-button
        icon="close"
        category="tertiary"
        class="gl-absolute gl-right-1"
        @click="hideDropdown"
      />
    </div>
    <gl-dropdown-divider />
    <gl-search-box-by-type v-model="groupSearch" class="m-2" :debounce="500" @input="fetchGroups" />
    <gl-dropdown-item
      class="gl-border-b-solid gl-border-b-gray-100 gl-border-b-1 gl-pb-2! gl-mb-2"
      :is-check-item="true"
      :is-checked="isGroupSelected($options.ANY.id)"
      @click="handleGroupChange($options.ANY.id)"
    >
      {{ $options.ANY.name }}
    </gl-dropdown-item>
    <div v-if="!fetchingGroups">
      <gl-dropdown-item
        v-for="group in groups"
        :key="group.id"
        :is-check-item="true"
        :is-checked="isGroupSelected(group.id)"
        @click="handleGroupChange(group.id)"
      >
        {{ group.full_name }}
      </gl-dropdown-item>
    </div>
    <div v-if="fetchingGroups" class="mx-3 mt-2">
      <gl-skeleton-loader :height="100">
        <rect y="0" width="90%" height="20" rx="4" />
        <rect y="40" width="70%" height="20" rx="4" />
        <rect y="80" width="80%" height="20" rx="4" />
      </gl-skeleton-loader>
    </div>
  </gl-dropdown>
</template>
