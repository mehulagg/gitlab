<script>
import {
  GlDeprecatedDropdown,
  GlDeprecatedDropdownDivider,
  GlDeprecatedDropdownHeader,
  GlDeprecatedDropdownItem,
} from '@gitlab/ui';

import { s__, __ } from '~/locale';

const issueActionItems = [
  {
    title: __('Add a new issue'),
    eventName: 'showCreateIssueForm',
  },
  {
    title: __('Add an existing issue'),
    eventName: 'showAddIssueForm',
  },
];

const epicActionItems = [
  {
    title: s__('Epics|Add a new epic'),
    eventName: 'showCreateEpicForm',
  },
  {
    title: s__('Epics|Add an existing epic'),
    eventName: 'showAddEpicForm',
  },
];

export default {
  epicActionItems,
  issueActionItems,
  components: {
    GlDeprecatedDropdown,
    GlDeprecatedDropdownDivider,
    GlDeprecatedDropdownHeader,
    GlDeprecatedDropdownItem,
  },
  props: {
    allowSubEpics: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    change({ eventName }) {
      this.$emit(eventName);
    },
  },
};
</script>

<template>
  <gl-deprecated-dropdown
    :text="__('Add')"
    variant="secondary"
    data-qa-selector="epic_issue_actions_split_button"
    right
  >
    <gl-deprecated-dropdown-header>{{ __('Issue') }}</gl-deprecated-dropdown-header>
    <gl-deprecated-dropdown-item
      v-for="item in $options.issueActionItems"
      :key="item.eventName"
      active-class="is-active"
      @click="change(item)"
    >
      {{ item.title }}
    </gl-deprecated-dropdown-item>
    <template v-if="allowSubEpics">
      <gl-deprecated-dropdown-divider />
      <gl-deprecated-dropdown-header>{{ __('Epic') }}</gl-deprecated-dropdown-header>
      <gl-deprecated-dropdown-item
        v-for="item in $options.epicActionItems"
        :key="item.eventName"
        active-class="is-active"
        @click="change(item)"
      >
        {{ item.title }}
      </gl-deprecated-dropdown-item>
    </template>
  </gl-deprecated-dropdown>
</template>
