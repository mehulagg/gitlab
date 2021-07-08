<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import Avatar from '~/vue_shared/components/deprecated_project_avatar/default.vue';
import { TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS } from '../constants';
import HiddenGroupsItem from './hidden_groups_item.vue';

const types = [TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS];

export default {
  components: {
    GlButton,
    Avatar,
    HiddenGroupsItem,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
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
};
</script>

<template>
  <transition name="fade">
    <li class="d-flex align-items-center px-3">
      <hidden-groups-item v-if="isHiddenGroups" />
      <template v-else>
        <avatar :project="approver" :size="24" /><span>{{ displayName }}</span>
      </template>
      <gl-button
        v-gl-tooltip
        class="ml-auto"
        icon="remove"
        :aria-label="__('Remove')"
        :title="__('Remove')"
        @click="$emit('remove', approver)"
      />
    </li>
  </transition>
</template>
