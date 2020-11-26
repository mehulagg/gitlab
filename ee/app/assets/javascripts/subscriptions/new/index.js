import Vue from 'vue';
import createStore from './store';
import Checkout from './components/checkout.vue';
import OrderSummary from './components/order_summary.vue';

export default () => {
  const checkoutEl = document.getElementById('checkout');
  const summaryEl = document.getElementById('summary');
  const store = createStore(checkoutEl.dataset);

  // eslint-disable-next-line no-new
  new Vue({
    el: checkoutEl,
    store,
    render(createElement) {
      return createElement(Checkout);
    },
  });

  return new Vue({
    el: summaryEl,
    store,
    render(createElement) {
      return createElement(OrderSummary);
    },
  });
};
