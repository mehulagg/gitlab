import Vue from 'vue';

export default () => {
  const checkoutEl = document.getElementById('checkout');
  const summaryEl = document.getElementById('summary');

  // eslint-disable-next-line no-new
  new Vue({
    el: checkoutEl,
    render(createElement) {
      return createElement();
    },
  });

  return new Vue({
    el: summaryEl,
    render(createElement) {
      return createElement();
    },
  });
};
