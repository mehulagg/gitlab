<script>
import ConfigurationTable from './configuration_table.vue';

export default {
  components: {
    ConfigurationTable
  }
};
</script>

<template>
  <article>
    <header>
      <h4 class="my-3">{{ __('Security Configuration') }}</h4>
      <h5 class="gl-font-lg mt-5">{{ s__('SecurityConfiguration|Testing & Compliance') }}</h5>
    </header>
    <configuration-table />
  </article>
</template>
