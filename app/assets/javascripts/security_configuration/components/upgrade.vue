<script>
import { GlLink, GlSprintf } from '@gitlab/ui';

export default {
  components: {
    GlLink,
    GlSprintf,
  },
};
</script>

<template>
  <span data-test-id="upgrade">
    <gl-sprintf :message="s__('Available with %{linkStart}upgrade or free trial%{linkEnd}')">
      <template #link="{ content }">
        <gl-link target="_blank" :href="'http://www.TOBEDEFINED'" data-testid="docsLink">
          {{ content }}
        </gl-link>
      </template>
    </gl-sprintf>
  </span>
</template>
