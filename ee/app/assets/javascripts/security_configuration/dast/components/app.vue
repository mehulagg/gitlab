<script>
import { GlTab, GlTabs } from '@gitlab/ui';
import { s__ } from '~/locale';
import DastConfigurationForm from './configuration_form.vue';

export default {
  components: {
    DastConfigurationForm,
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
    dastSettings() {
      return [
        {
          title: s__('DastConfig|Scan Configuration'),
          component: DastConfigurationForm,
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
      <gl-tab v-for="(tab, index) in dastSettings" :key="index">
        <template #title>
          <span>{{ tab.title }}</span>
        </template>

        <component :is="dastSettings[index].component" />
      </gl-tab>
    </gl-tabs>
  </article>
</template>
