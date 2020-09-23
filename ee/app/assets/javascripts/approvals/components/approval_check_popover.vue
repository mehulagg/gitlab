<script>
import { GlLink, GlPopover, GlIcon } from '@gitlab/ui';

export default {
  name: 'ApprovalCheckPopover',
  components: {
    GlLink,
    GlPopover,
    GlIcon,
  },
  props: {
    documentationLink: {
      type: String,
      required: false,
      default: '',
    },
    documentationText: {
      type: String,
      required: false,
      default: '',
    },
    title: {
      type: String,
      required: true,
    },
    text: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <span class="vertical-align-middle text-muted js-help">
    <gl-icon
      ref="reportInfo"
      name="question"
      class="text-info"
      :aria-label="__('help')"
      :size="14"
    />
    <gl-popover
      :target="() => $refs.reportInfo.$el"
      placement="top"
      triggers="click blur"
      :title="title"
    >
      <div class="mb-2">{{ text }}</div>
      <gl-link v-if="documentationLink" target="_blank" :href="documentationLink">
        <span class="vertical-align-middle">{{ documentationText }}</span>
        <gl-icon name="external-link" class="vertical-align-middle" />
      </gl-link>
    </gl-popover>
  </span>
</template>
