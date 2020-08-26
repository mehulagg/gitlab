<script>
import { GlDeprecatedBadge as GlBadge, GlPopover } from '@gitlab/ui';

export default {
  name: 'RemediatedBadge',
  components: {
    GlBadge,
    GlPopover,
  },

  emits: [],
};
</script>

<template>
  <div class="d-inline-block">
    <gl-badge ref="badge" variant="info">{{ __('Remediated: needs review') }}</gl-badge>
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
