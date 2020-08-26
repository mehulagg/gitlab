<script>
import { GlDeprecatedButton, GlIcon } from '@gitlab/ui';
import Avatar from '~/vue_shared/components/project_avatar/default.vue';
import HiddenGroupsItem from './hidden_groups_item.vue';
import { TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS } from '../constants';

const types = [TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS];

export default {
  components: {
    GlDeprecatedButton,
    GlIcon,
    Avatar,
    HiddenGroupsItem,
  },
  props: {
    approver: {
      type: Object,
      required: true,
      validator: ({ type }) => type && types.indexOf(type) >= 0,
    },
  },
  computed: {
    isGroup() {
      return this.approver.type === TYPE_GROUP;
    },
    isHiddenGroups() {
      return this.approver.type === TYPE_HIDDEN_GROUPS;
    },
    displayName() {
      return this.isGroup ? this.approver.full_path : this.approver.name;
    },
  },

  emits: ['remove'],
};
</script>

<template>
  <transition name="fade">
    <li class="d-flex align-items-center px-3">
      <hidden-groups-item v-if="isHiddenGroups" />
      <template v-else>
        <avatar :project="approver" :size="24" /><span>{{ displayName }}</span>
      </template>
      <gl-deprecated-button variant="none" class="ml-auto" @click="$emit('remove', approver)">
        <gl-icon name="remove" :aria-label="__('Remove')" />
      </gl-deprecated-button>
    </li>
  </transition>
</template>
