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
      <h4 data-test-id="security-configuration-primary-heading" class="my-3">{{ __('Security Configuration') }}</h4>
      <h5 data-test-id="security-configuration-secondary-heading" class="gl-font-lg mt-5">{{ s__('SecurityConfiguration|Testing & Compliance') }}</h5>
    </header>
    <configuration-table />
  </article>
</template>
