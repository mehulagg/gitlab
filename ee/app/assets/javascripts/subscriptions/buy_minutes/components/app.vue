<script>
import StepOrderApp from 'ee/vue_shared/purchase_flow/components/step_order_app.vue';
import Checkout from './checkout.vue';

export default {
  components: {
    Checkout,
    StepOrderApp,
  },
};
</script>
<template>
  <step-order-app>
    <template #checkout>
      <checkout />
    </template>
    <template #order-summary></template>
  </step-order-app>
</template>
