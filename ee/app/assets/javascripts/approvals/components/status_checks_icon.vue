<script>
import { GlIcon, GlPopover } from '@gitlab/ui';
import { uniqueId } from 'lodash';
import { s__ } from '~/locale';

export default {
  components: {
    GlIcon,
    GlPopover,
  },
  props: {
    url: {
      type: String,
      required: true,
    },
  },
  computed: {
    iconId() {
      return uniqueId('status-checks-icon-');
    },
    containerId() {
      return uniqueId('status-checks-icon-container-');
    },
  },
  i18n: {
    title: s__('StatusCheck|Status to check'),
  },
};
</script>

<template>
  <div :id="containerId">
    <gl-icon :id="iconId" name="api" />
    <gl-popover
      :target="iconId"
      :container="containerId"
      placement="top"
      :title="$options.i18n.title"
      triggers="hover focus"
      :content="url"
    />
  </div>
</template>
