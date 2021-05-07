<script>
import StepOrderApp from 'ee/vue_shared/purchase_flow/components/step_order_app.vue';
import Checkout from './checkout.vue';
import OrderSummary from './order_summary.vue';

export default {
  components: {
    StepOrderApp,
    Checkout,
    OrderSummary,
  },
};
</script>
<template>
  <step-order-app>
    <template #checkout>
      <checkout />
    </template>
    <template #order-summary>
      <order-summary />
    </template>
  </step-order-app>
</template>
