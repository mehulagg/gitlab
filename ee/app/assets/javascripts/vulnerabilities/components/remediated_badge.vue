<script>
import { GlIcon, GlPopover, GlBadge } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlPopover,
    GlBadge,
  },
  computed: {
    target() {
      return this.$refs.badge?.$el;
    },
  },
};
</script>

<template>
  <div class="gl-display-inline-block">
    <gl-badge ref="badge" variant="info">
      <gl-icon name="admin" />
    </gl-badge>
    <gl-popover
      ref="popover"
      :content="
        __(
          'The vulnerability is no longer detected. Verify the vulnerability has been fixed or removed before changing its status.',
        )
      "
      :target="() => target"
      :title="__('Vulnerability remediated. Review before resolving.')"
      placement="top"
      triggers="hover focus"
    />
  </div>
</template>
