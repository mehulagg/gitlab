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
  data() {
    return {
      tabIndex: 0,
    };
  },
  computed: {
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
          {{ tab.title }}
        </template>

        <component :is="tab.component" />
      </gl-tab>
    </gl-tabs>
  </article>
</template>
