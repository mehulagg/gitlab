<script>
import { GlIcon, GlPopover } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlPopover,
  },
};
</script>

<template>
  <div class="gl-display-inline-block">
    <span class="gl-display-inline-block gl-rounded-lg gl-bg-blue-200 gl-text-blue-500 gl-px-3">
      <gl-icon ref="badge" name="admin" />
    </span>
    <gl-popover
      ref="popover"
      :content="
        __(
          'The vulnerability is no longer detected. Verify the vulnerability has been fixed or removed before changing its status.',
        )
      "
      :target="() => $refs.badge.$el"
      :title="__('Vulnerability remediated. Review before resolving.')"
      placement="top"
      triggers="hover focus"
    />
  </div>
</template>
