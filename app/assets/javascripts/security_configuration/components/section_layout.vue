<script>
export default {
  name: 'SectionLayout',
  props: {
    heading: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div class="row">
    <div class="col-lg-5">
      <h2 class="gl-font-size-h2 gl-mt-0" data-test-id="layout-heading">{{ heading }}</h2>
      <slot name="latest-pipeline"></slot>
    </div>
    <div class="col-lg-7">
      <slot name="features"></slot>
    </div>
  </div>
</template>
