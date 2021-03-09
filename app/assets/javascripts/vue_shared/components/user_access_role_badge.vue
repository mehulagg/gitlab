<script>
import { GlBadge } from '@gitlab/ui';

export default {
  name: 'UserAccessRoleBadge',
  components: {
    GlBadge,
  },
};
</script>

<template>
  <gl-badge class="gl-bg-transparent! gl-inset-border-1-gray-100!">
    <slot></slot>
  </gl-badge>
</template>
