<script>
import { GlTab, GlTabs } from '@gitlab/ui';
import DastScanConfiguration from './scan_configuration.vue';

export default {
  components: {
    DastScanConfiguration,
    GlTab,
    GlTabs,
  },
  computed: {
    tabIndex: {
      get() {
        return 0;
      },
      set(newTabIndex) {
        return newTabIndex;
      },
    },
    tabSettings() {
      return [
        {
          title: 'Scan Configuration',
        },
      ];
    },
  },
};
</script>

<template>
  <article>
    <header class="gl-my-5">
      <h4>
        {{ s__('DastConfig|DAST Settings') }}
      </h4>
    </header>

    <gl-tabs v-model="tabIndex">
      <gl-tab v-for="(tab, index) in tabSettings" :key="index">
        <template #title>
          <span>{{ tab.title }}</span>
        </template>
        <dast-scan-configuration />
      </gl-tab>
    </gl-tabs>
  </article>
</template>
