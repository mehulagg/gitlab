<script>
import { GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    isEmpty: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  // The fixed height prevents the tab-content from jumping around and is set to match the other widgets
  // within the aside.
  // Details: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/24242#note_282008456
  wrapperHeight: '15rem',
};
</script>

<template>
  <div class="mx-3 my-2 overflow-auto" :style="{ height: $options.wrapperHeight }">
    <gl-loading-icon v-if="isLoading" size="sm" />
    <template v-else>
      <template v-if="!isEmpty">
        <slot></slot>
      </template>
      <p v-else class="mb-0">
        {{ s__('UnscannedProjects|Your projects are up do date! Nice job!') }}
      </p>
    </template>
  </div>
</template>
