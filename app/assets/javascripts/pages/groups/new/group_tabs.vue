<script>
import { GlTabs, GlTab } from '@gitlab/ui';

export default {
  components: {
    GlTabs,
    GlTab,
  },
};
</script>

<template>
  <gl-tabs content-class="gl-display-none" justified v-on="$listeners">
    <gl-tab no-body>
      <template #title>
        <span class="d-none d-sm-block">{{ s__('GroupsNew|Create group') }}</span>
        <span class="d-block d-sm-none">{{ s__('GroupsNew|Create') }}</span>
      </template>
    </gl-tab>
    <gl-tab no-body>
      <template #title>
        <span class="d-none d-sm-block">{{ s__('GrouGroupsNew|Import group') }}</span>
        <span class="d-block d-sm-none">{{ s__('GroupsNew|Import') }}</span>
      </template>
    </gl-tab>
  </gl-tabs>
</template>
