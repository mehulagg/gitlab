<script>
import DastScanConfiguration from './scan_configuration.vue';

export default {
  components: {
    DastScanConfiguration,
  },
};
</script>

<template>
  <article>
    <header class="gl-mt-5 gl-border-b-1 gl-border-b-gray-100 gl-border-b-solid">
      <h4>
        {{ s__('DastConfig|DAST Settings') }}
      </h4>
    </header>

    <dast-scan-configuration />
  </article>
</template>
