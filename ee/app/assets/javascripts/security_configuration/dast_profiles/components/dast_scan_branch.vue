<script>
import { GlLink, GlIcon } from '@gitlab/ui';
import { isString, isBoolean } from 'lodash';

export default {
  name: 'DastScanBranch',
  components: {
    GlLink,
    GlIcon,
  },
  props: {
    branch: {
      type: Object,
      required: true,
      validator: ({ name, exists }) => isString(name) && isBoolean(exists),
    },
    editPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <template v-if="branch.exists">
      <gl-icon name="branch" />
      {{ branch.name }}
    </template>
    <template v-else>
      <span class="gl-text-red-500">
        <gl-icon name="warning" />
        {{ s__('DastProfiles|Branch missing') }}
      </span>
      • <gl-link :href="editPath">{{ s__('DastProfiles|Select branch') }}</gl-link>
    </template>
  </div>
</template>
